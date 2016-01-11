# Git的使用

### Add Reviewer
编辑 ```.git/config```
```
receivepack = git receive-pack --reviewer reviewer1 --reviewer reviewer2
```

### Rewrite History
```bash
git filter-branch --tree-filter `rm -rf path/to/folder`
git push origin --force
```
[document](http://git-scm.com/docs/git-filter-branch)

### Branch Merge
1.git fetch
2.git checkout -b B origin/B
3.git merge --no-ff origin/A
4.git commit --amend
5.git push origin HEAD:refs/for/B

### Add tag
git tag -a v0.0.1 -m "Release Version 0.0.1"
git push origin v0.0.1

### Reference
- [Git Magic](http://www-cs-students.stanford.edu/~blynn/gitmagic/intl/zh_cn/index.html) - Git简要教程
- [Git from the inside out](https://codewords.recurse.com/issues/two/git-from-the-inside-out)
- [高富帅们的Git技巧](http://cloudbbs.org/forum.php?tid=30647&page=1&extra=&mod=viewthread#pid201033) - Git使用技巧
- [How to install the latest GIT version on CentOS](https://www.howtoforge.com/how-to-install-the-latest-git-version-on-centos)
- [Caching your GitHub password in Git](https://help.github.com/articles/caching-your-github-password-in-git/)
- [Pre Commit](http://pre-commit.com/) -- Managing and maintaining multi-language pre-commit hooks
- [How to undo (almost) anything with Git](https://github.com/blog/2019-how-to-undo-almost-anything-with-git)
- [Git Workflow Toturial](https://github.com/xirong/my-git/blob/master/git-workflow-tutorial.md)
- [10 tips for better Pull Requests](http://blog.ploeh.dk/2015/01/15/10-tips-for-better-pull-requests/) - by Mark Seemann
