package main

import (
	"bufio"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"reflect"
	"strings"

	"github.com/capturealpha/gitblox/git-remote-gitblox/internal/path"
	"github.com/cryptix/go/logging"
	shell "github.com/ipfs/go-ipfs-api"
	"github.com/pkg/errors"
)

const usageMsg = `usage git-remote-gitblox <repository> [<URL>]
supports:

* gitblox://ipfs/$hash/path..
* gitblox:///ipfs/$hash/path..

`

func usage() {
	fmt.Fprint(os.Stderr, usageMsg)
	os.Exit(2)
}

var (
	ref2hash = make(map[string]string)

	ipfsShell     = shell.NewShell("localhost:5001")
	ipfsRepoPath  string
	thisGitRepo   string
	thisGitRemote string
	log           logging.Interface
	check         = logging.CheckFatal
)

func logFatal(msg string) {
	log.Log("event", "fatal", "msg", msg)
	os.Exit(1)
}

func main() {
	// logging
	logging.SetupLogging(nil)
	log = logging.Logger("git-remote-gitblox")

	// env var and arguments
	thisGitRepo = os.Getenv("GIT_DIR")
	log.Log("GIT_DIR", thisGitRepo)

	if thisGitRepo == "" {
		logFatal("could not get GIT_DIR env var")
	}
	if thisGitRepo == ".git" {
		cwd, err := os.Getwd()
		logging.CheckFatal(err)
		thisGitRepo = filepath.Join(cwd, ".git")
	}

	var u string // repo url
	v := len(os.Args[1:])
	switch v {
	case 2:
		thisGitRemote = os.Args[1]
		u = os.Args[2]
	default:
		logFatal(fmt.Sprintf("usage: unknown # of args: %d\n%v", v, os.Args[1:]))
	}

	log.Log("thisGitRemote", thisGitRemote)
	log.Log("u", u)

	// parse passed URL
	for _, pref := range []string{"gitblox://ipfs/", "gitblox:///ipfs/"} {
		if strings.HasPrefix(u, pref) {
			u = "/ipfs/" + u[len(pref):]
		}
	}
	log.Log("u", u)
	parts := strings.Split(u, "/")
	log.Log("parts", parts[0])
	p, err := path.ParsePath(u)
	check(err)

	ipfsRepoPath = p.String()
	log.Log("ipfsRepoPath", ipfsRepoPath)

	// interrupt / error handling
	go func() {
		check(interrupt())
	}()

	//refsCat, err := ipfsShell.Cat(filepath.Join(ipfsRepoPath, "info", "refs"))
	ls, err := ipfsShell.List(filepath.Join(ipfsRepoPath, "info", "refs"))
	if err != nil {
		fmt.Fprintf(os.Stderr, "error: %s", err)
		os.Exit(1)
	}
	if ls == nil {
		fmt.Println("ls=nil")
		os.Exit(1)
	}

	for index, element := range ls {
		log.Log("At index", index, "value is", element.Name)
	}

	check(speakGit(os.Stdin, os.Stdout))
}

// speakGit acts like a git-remote-helper
// see this for more: https://www.kernel.org/pub/software/scm/git/docs/gitremote-helpers.html
func speakGit(r io.Reader, w io.Writer) error {
	//debugLog := logging.Logger("git")
	//r = debug.NewReadLogrus(debugLog, r)
	//w = debug.NewWriteLogrus(debugLog, w)
	scanner := bufio.NewScanner(r)
	for scanner.Scan() {
		text := scanner.Text()
		log.Log("text", text)
		switch {

		case text == "capabilities":
			fmt.Fprintln(w, "fetch")
			fmt.Fprintln(w, "push")
			fmt.Fprintln(w, "")

		case strings.HasPrefix(text, "list"):
			var (
				forPush = strings.Contains(text, "for-push")
				err     error
				head    string
			)
			if err = listInfoRefs(forPush); err == nil { // try .git/info/refs first
				if head, err = listHeadRef(); err != nil {
					return err
				}
			} else { // alternativly iterate over the refs directory
				if forPush {
					log.Log("msg", "for-push: should be able to push to non existant.. TODO #2")
				}
				log.Log("err", err, "msg", "didn't find info/refs in repo, falling back...")
				if err = listIterateRefs(forPush); err != nil {
					return err
				}
			}
			if len(ref2hash) == 0 {
				return errors.New("did not find _any_ refs...")
			}
			// output
			for ref, hash := range ref2hash {
				if head == "" && strings.HasSuffix(ref, "master") {
					// guessing head if it isnt set
					head = hash
				}
				fmt.Fprintf(w, "%s %s\n", hash, ref)
			}
			fmt.Fprintf(w, "%s HEAD\n", head)
			fmt.Fprintln(w)

		case strings.HasPrefix(text, "fetch "):
			for scanner.Scan() {
				fetchSplit := strings.Split(text, " ")
				if len(fetchSplit) < 2 {
					return errors.Errorf("malformed 'fetch' command. %q", text)
				}
				err := fetchObject(fetchSplit[1])
				if err == nil {
					fmt.Fprintln(w)
					continue
				}
				// TODO isNotExist(err) would be nice here
				//log.Log("sha1", fetchSplit[1], "name", fetchSplit[2], "err", err, "msg", "fetchLooseObject failed, trying packed...")

				err = fetchPackedObject(fetchSplit[1])
				if err != nil {
					return errors.Wrap(err, "fetchPackedObject() failed")
				}
				text = scanner.Text()
				if text == "" {
					break
				}
			}
			fmt.Fprintln(w, "")

		case strings.HasPrefix(text, "push"):
			for scanner.Scan() {
				pushSplit := strings.Split(text, " ")
				if len(pushSplit) < 2 {
					return errors.Errorf("malformed 'push' command. %q", text)
				}
				srcDstSplit := strings.Split(pushSplit[1], ":")
				if len(srcDstSplit) < 2 {
					return errors.Errorf("malformed 'push' command. %q", text)
				}
				src, dst := srcDstSplit[0], srcDstSplit[1]
				f := []interface{}{
					"src", src,
					"dst", dst,
				}
				log.Log(append(f, "msg", "got push"))
				if src == "" {
					fmt.Fprintf(w, "error %s %s\n", dst, "delete remote dst: not supported yet - please open an issue on github")
				} else {
					if err := push(src, dst); err != nil {
						fmt.Fprintf(w, "error %s %s\n", dst, err)
						return err
					}
					fmt.Fprintln(w, "ok", dst)
				}
				text = scanner.Text()
				if text == "" {
					break
				}
			}
			fmt.Fprintln(w, "")

		case text == "":
			break

		default:
			return errors.Errorf("Error: default git speak: %q", text)
		}
	}
	if err := scanner.Err(); err != nil {
		return errors.Wrap(err, "scanner.Err()")
	}
	return nil
}
