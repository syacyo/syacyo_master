#!/bin/bash

pattern=$1
find . -type f | xargs grep -nH "$pattern"

