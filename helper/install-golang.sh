#!/bin/bash

echo ">> Install Golang"

# Detect system architecture
ARCH="$(uname -m)"
if [ "$ARCH" = "x86_64" ]; then
	GOARCH="amd64"
elif [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
	GOARCH="arm64"
else
	echo "Unsupported architecture: $ARCH"
	exit 1
fi

VERSION="$(curl -s https://go.dev/VERSION?m=text)"
ARCHIVE="$VERSION.linux-$GOARCH.tar.gz"
wget -q -O /tmp/$ARCHIVE https://go.dev/dl/$ARCHIVE
tar -C /usr/local -xzf /tmp/$ARCHIVE
ln -sf /usr/local/go/bin/go /usr/local/bin/go
ln -sf /usr/local/go/bin/gofmt /usr/local/bin/gofmt
rm /tmp/$ARCHIVE

echo ">> Install gopls"
GOPATH=/tmp/go go install golang.org/x/tools/gopls@latest
cp /tmp/go/bin/gopls /usr/local/go/bin/gopls
ln -sf /usr/local/go/bin/gopls /usr/local/bin/gopls

exit 0
