#!/bin/bash
for util in find sort vim xclip cat clear pr ls grep
do
        if ! which $util > /dev/null 2>&1 
        then
                echo $util - fail
        else
                echo $util - ok
        fi
done
