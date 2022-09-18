#!/bin/bash

mkdir -p ~/gtd
mkdir -p ~/gtd/_today
export PATH=$PWD/bin:$PATH
bundle exec cards ~/gtd
