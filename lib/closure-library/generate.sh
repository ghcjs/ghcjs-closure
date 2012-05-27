#!/bin/bash
# cabal cannot properly pack lots of files in directory structures
# and unfortunately there is no way to specify dependencies for
# Setup.hs scripts, so it's risky to use tar or gzip functions
#
# Workaround:
# move all closure library files in one dir and sort them back into
# place with the Setup.hs script
#
# Underscore encoding:
# _  -> _u
# .  -> _d
# /  -> _s

svn export http://closure-library.googlecode.com/svn/trunk/ closure-library-read-only
rm -rf pkg
mkdir -p pkg
cp closure-library-read-only/README README
cp closure-library-read-only/AUTHORS AUTHORS
cp closure-library-read-only/LICENSE LICENSE
mkdir -p pkg
(
  cd closure-library-read-only
  for file in $(find .)
  do
    echo "copying $file"
    ufile=${file:2}         # remove leading ./
    ufile=${ufile//_/_u}    # -  => _u
    ufile=${ufile//./_d}    # .  => _d
    ufile=${ufile//\//_s}   # /  => _s
    cp "${file}" "../pkg/${ufile}.pkg"
  done  
)
rm -rf closure-library-read-only
