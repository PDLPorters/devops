# Testing environment

1. Debugging GitHub Actions can be done through SSH by using
   <https://github.com/mxschmitt/action-tmate> as below:

```yaml
      - name: Setup tmate session
        if: ${{ failure() }}
        uses: mxschmitt/action-tmate@v3
        with:
          limit-access-to-actor: true
```

2. Debugging locally can be done through VMs. One way to use a VM for Windows
   is to use Vagrant and install the box
   <https://app.vagrantup.com/StefanScherer/boxes/windows_10>.

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

## How to restructure repo into lib/*
```
for x in $(find * -name examples -prune -o -name blib -prune -o -name \*.pm -print)
do
  p=$(perl -nE 'next if !/^package\s+(\S+);$/; push @p, $1; END { say for @p }' $x)
  f=$(perl -e '@l = split /::/, shift; pop @l; print join "/", @l' $p)
  d=lib/$f
  echo mkdir -p $d
  echo git mv $x $d
done
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

# only on initial; afterwards, have to just deal with conflict in own work
git rebase -i pdla2.013 # edit VERSION commits to stop from updating VERSION
git checkout -b update-from-upstream-on-2.013009
git rebase -i master

# on conflict, if just want to get to supplied filestate for files
# instead of manually applying changes, but with renames:
# reporoot commit file...
updatefrom() {
  local dir="$1" commit="$2"; shift 2
  for file in "$@"
  do
    if [ -f "$file" ]; then
      (cd "$dir"; git show "$commit":"$file") |
        perl -p -e 's#PDL([^A])#PDLA$1#g' >"$file"
    fi
  done
}

# to get commit and file-list from `git am --show-current-patch`
commitfiles-from-current() {
  local text="$(git am --show-current-patch)"
  local commit="${text:5}"; commit="${commit%% *}"
  local files=$(
    local filelist="${text#*---}";
    filelist="${filelist%%diff*}" # zap from first "diff"
    filelist="${filelist%|*}" # zap from last "|"
    echo "$filelist" | while read name discard; do echo $name; done
  )
  echo "$commit" $files
}

# so:
updatefrom ../pdl-code $(commitfiles-from-current)

# then:
perl -pi -e 's#Pdlpp#Pdlapp#g' $(gg 'Pdlpp\b'|sed 's/:.*//'|g -v '^Changes'|sort -u) /dev/null

perl -pi -e 's#pdl2#pdla2#g' $(gg 'pdl2\b'|sed 's/:.*//'|g -v '^Changes'|sort -u) /dev/null

perl -pi -e 's#PDLAPorters/pdl#PDLPorters/pdla-core#g' $(gg 'PDLAPorters/pdl'|sed 's/:.*//'|g -v '^Changes'|sort -u) /dev/null

perl -pi -e 's#PDLAPorters#PDLPorters#g' $(gg 'PDLAPorters'|sed 's/:.*//'|g -v '^Changes'|sort -u) /dev/null

perl -pi -e 's#([\s'\'']+)pdl>#${1}pdla>#g' $(gg '[     '\'']pdl>'|sed 's/:.*//'|sort -u) /dev/null # second thing in [] is tab

perl -pi -e 's#\bperldl\b([^./'\''])([^m])?#perldla$1$2#g' $(gg '\bperldl\b[^\./'\'']'|g -v 'mailing list'|g -v '^Changes'|sed 's/:.*//'|sort -u) /dev/null

perl -pi -e 's#\bpdldoc\b#pdladoc#g' $(gg -l '\bpdldoc\b'|g -Ev '^(Changes|Known)'|sed 's/:.*//'|sort -u) /dev/null

perl -pi \
  -e 's#(\s)SymTab#${1}PDLA::PP::SymTab#g;' \
  -e 's#C::Type#PDLA::PP::CType#g;' \
  -e 's#XS(::mkproto)#PDLA::PP::$&#g;' \
  Basic/Gen/PP.pm

# also fixup FAQ "pdl," -> "pdla", "perldla mailing"
# fixup 'perldl' in Basic/Pod/QuickStart.pod Doc/Doc/Perldl.pm
```
