# Gitblox Remote Helper

`git-remote-helper` implements a git-remote helper that uses the ipfs transport.

### TODO

Currently assumes a IPFS Daemon at localhost:5001


### Usage

```
git clone gitblox://ipfs/$hash/repo.git
cd repo && make $stuff
git commit -a -m 'done!'
git push origin
```

### Links

- https://ipfs.io
- https://github.com/whyrusleeping/git-ipfs-rehost
- https://git-scm.com/docs/gitremote-helpers
- https://git-scm.com/book/en/v2/Git-Internals-Plumbing-and-Porcelain
- https://git-scm.com/docs/gitrepository-layout
- https://git-scm.com/book/en/v2/Git-Internals-Transfer-Protocols