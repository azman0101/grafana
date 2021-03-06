#!/bin/bash

#
#   This script is executed from within the container.
#

CCX64=/tmp/x86_64-centos6-linux-gnu/bin/x86_64-centos6-linux-gnu-gcc

GOPATH=/go
REPO_PATH=$GOPATH/src/github.com/grafana/grafana

cd /go/src/github.com/grafana/grafana
echo "current dir: $(pwd)"

if [ "$CIRCLE_TAG" != "" ]; then
  echo "Building releases from tag $CIRCLE_TAG"
  OPT="-includeBuildNumber=false"
else
  echo "Building incremental build for $CIRCLE_BRANCH"
  OPT="-buildNumber=${CIRCLE_BUILD_NUM}"
fi

CC=${CCX64} go run build.go ${OPT} build

yarn install --pure-lockfile --no-progress

echo "current dir: $(pwd)"

if [ -d "dist" ]; then
  rm -rf dist
fi

echo "Building frontend"
go run build.go ${OPT} build-frontend

echo "Packaging"
go run build.go -goos linux -pkg-arch amd64 ${OPT} package-only latest
