#!/bin/bash

extra=''

git status|grep "On branch main"
if [ $? == 1 ]; then
  extra="-except=upload"
  echo "Not on main branch. Will skip upload."
fi

export password=`openssl rand -base64 9`
echo "password: ${password}"

hash=`openssl passwd -6 $password`

sed -i -E "s|\-\-password=.*|--password=$hash|g" http/ks.cfg

packer build ${extra} --force template.json

sed -i -E "s|\-\-password=.*|--password=randpass|g" http/ks.cfg
