#!/bin/bash

GITHUB="https://api.github.com/repos/xenserver/xe-guest-utilities/releases/latest"

SUDO=sudo
if [ $(id -u) -eq 0 ]; then
    SUDO=
fi

if [ -z "$(which curl)" ]; then
    echo "Curl is required"
    exit 1
fi

if [ ! -z "$(which rpm)" ]; then
    echo "Using the RPM package manager!"
    MANAGER="rpm"
elif [ ! -z "$(which dpkg)" ]; then
    echo "Using the dpkg package manager!"
    MANAGER="deb"
else
    echo "Unsupported package manager!"
    exit 1
fi

ARCH=$(uname -m)

case $ARCH in
    amd64|x86_64)
        if [ "$MANAGER" = "rpm" ]; then
            ARCH="x86_64"
        else
            ARCH="amd64"
        fi
        ;;
    i386|x86)
        ARCH="i386"
        ;;
    *)
        echo "Unsupported architecrure $ARCH"
        exit 1
        ;;
esac

RELEASE=$(echo $(curl -sfL $GITHUB | grep "$ARCH.$MANAGER") | grep -o '[^ ]*$')
RELEASE=${RELEASE:1:-1}
FILENAME=${RELEASE##*/}

echo "Downloading $FILENAME"
$SUDO curl -sLO $RELEASE

echo "Installing $FILENAME"
if [ "$MANAGER" = "rpm" ]; then
   $SUDO rpm -qpR $FILENAME
else
   $SUDO apt install $FILENAME
fi

echo "Removing file $FILENAME"
$SUDO rm $FILENAME
