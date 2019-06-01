#!/bin/bash

git pull
git add .
TIME=`date`
git commit -am "last updates done at $TIME"
git push
