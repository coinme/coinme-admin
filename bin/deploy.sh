#!/bin/sh

eb list | grep \* > /dev/null

if [ $? -ne 0 ]; then
    echo 'You need to select a deployment environment. run: eb use <enironment name> or eb create'
    exit 1
fi

eb deploy --staged
