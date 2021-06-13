#!/bin/sh

BASE_URL=https://github.com/mercari/tfnotify/release/download

DOWNLOAD_URL="${BASE_URL}/v0.6.1/tfnotify_linux_amd64.tar.gz"

wget ${DOWNLOAD_URL} -P /tmp
tar zxvf /tmp/tfnotify_linux_amd64.tar.gza -C /tmp
mv /tmp/tfnotify_linux_amd64/tfnotify /usr/local/bin/tfnotify