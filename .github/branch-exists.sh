#!/bin/bash

b="main"

a=`git rev-parse --verify --quiet main`
exit_code=$?
echo ${exit_code}
echo $a