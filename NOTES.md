# Split

## Create repo

```
REPO_NAME="..."
# git hub can be installed by running `cpanm App::git::hub`
git hub repo-new PDLPorters/$REPO_NAME
```

## Enchant

```markdown
- [ ] Travis-CI <https://travis-ci.org/PDLPorters/$REPO> (https://travis-ci.org/profile/PDLPorters)
- [ ] Appveyor CI (https://ci.appveyor.com/)
- [ ] Coveralls <https://coveralls.io/r/PDLPorters/$REPO> (https://coveralls.io/repos/new?name=PDLPorters)
- [ ] IRC notifications (handled by devops `enchant` script)
```

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
- [ ] check that Appveyor builds work
- [ ] add badges to README (coverage, CI, etc.)
- [ ] prep `Changes` for new version. Make note that the next release is its own repo and distro
- [ ] add `xt/00-check-changelog.t` test
- [ ] add `.gitignore`
- [ ] add a test to check that `pdldoc` indexing works for the new dist
- [ ] make sure all the configuration options for BAD values are tried by Travis-CI (settings are in `perldl.conf`)

[pdl split meta-issue](https://github.com/PDLPorters/pdl/issues/119)
```

See <https://github.com/PDLPorters/pdl-io-gd/issues/3> for an example.

For information about Appveyor, see <https://github.com/PDLPorters/pdl/issues/130>.

## How to mirror a repository

```shell
git clone --bare git@github.com:PDLPorters/pdl.git;
cd pdl.git;
git push --mirror git@github.com:PDLPorters/pdla.git
```

from <https://help.github.com/articles/duplicating-a-repository/#mirroring-a-repository>.

## Renaming a namespace

```shell
perl -pi -e 's#PDL([^A])#PDLA$1#g' $(git grep -l PDL)
```

Checklist

- [ ] Make sure that the changelog is not affected by the rename.
- [ ] Modify README.md to fix the badges
