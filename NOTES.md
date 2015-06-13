# Split

## Create repo

```
REPO_NAME="..."
# git hub can be installed by running `cpanm App::git::hub`
git hub repo-new PDLPorters/$REPO_NAME
```

## Enchant

```shell
./tool/enchant $REPO_NAME
```


## How to split history
Make sure `git-subtree` is installed and works (if not, get from
https://github.com/git/git/blob/master/contrib/subtree/git-subtree.sh and place
with `+x` in `/usr/local/libexec/git-core/git-subtree`)
```shell
    # example for pdl-io-gd
    cd $PDLREPODIR
    git subtree split -P IO/GD -b p-i-g
    cd $PIGDIR
    git pull $PDLREPODIR p-i-g
```

## Add split task issue for repository

```markdown
- [ ] standalone `Makefile.PL`
- [ ] add repository info to metadata (`Makefile.PL`'s `META_MERGE`)
- [ ] make sure PDL tests for this module are available
- [ ] check that Travis-CI builds work
- [ ] add badges to README (coverage, etc.)
- [ ] prep `Changes` for new version. Make note that the next release is its own repo and distro
- [ ] add `xt/00-check-changelog.t` test
- [ ] add `.gitignore`

[pdl split meta-issue](https://github.com/PDLPorters/pdl/issues/119)
```

See <https://github.com/PDLPorters/pdl-io-gd/issues/3> for an example.
