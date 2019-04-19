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
# example for pdla-io-hdf
KITCHENSINKREPO=$HOME/pdla
KITCHENSINKDIR=IO/HDF
SPLITOUTREPO=$HOME/pdla-io-hdf
SPLITBRANCH=splitout
MASTER=master
pushd $KITCHENSINKREPO
git subtree split -P $KITCHENSINKDIR -b $SPLITBRANCH
git push $SPLITOUTREPO $SPLITBRANCH:$SPLITBRANCH
git branch -D $SPLITBRANCH
cd $SPLITOUTREPO
git checkout $MASTER
git reset --hard $SPLITBRANCH
git branch -d $SPLITBRANCH
git push origin
popd
```

## Add split task issue for repository

```markdown
- [ ] standalone `Makefile.PL`
- [ ] add repository info to metadata (`Makefile.PL`'s `META_MERGE`)
- [ ] make sure PDLA tests for this module are available
- [ ] check that Travis-CI builds work
- [ ] check that Appveyor builds work
- [ ] add badges to README (coverage, CI, etc.)
- [ ] prep `Changes` for new version. Make note that the next release is its own repo and distro
- [ ] add `xt/00-check-changelog.t` test
- [ ] add `.gitignore`
- [ ] add a test to check that `pdladoc` indexing works for the new dist
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
- [ ] Ensure when zapping from previous (probably -rest) that any `DIR` reference is zapped
- [ ] From -rest, zap from `MANIFEST`, `MANIFEST.SKIP`, `.gitignore`

## How to update from upstream

```shell
mkdir td
git format-patch -o td b26afaae..v2.014
mv td ..
cd ../td
git init
git commit --allow-empty -m empty
git add .
git commit -am 'gen-ed'
perl -pi -e 's#PDL([^A])#PDLA$1#g' *
git commit -am 'perl -pi -e '\''s#PDL([^A])#PDLA$1#g'\'' *'
# consider also zapping VERSION and Changes updates

cd ../pdla-core
git checkout -b update-from-upstream pdla2.013 # that's after big rename
git am ../td/*
git rebase -i pdla2.013 # edit VERSION commits to stop from updating VERSION
git checkout -b update-from-upstream-on-2.013009
git rebase -i master
```
