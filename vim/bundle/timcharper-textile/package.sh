#!/bin/bash

cd `dirname "$0"`
VERSION=`git tag | sort_rev | tail -n 1`
git archive --prefix=textile/ $VERSION | tar xf -
rm textile/.gitignore textile/package.sh

zip -r textile-$VERSION.zip textile
rm -rf textile
