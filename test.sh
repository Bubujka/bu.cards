#!/bin/bash
for util in find sort vim xclip
do
        if ! which $util > /dev/null 2>&1 
        then
                echo $util - fail
        else
                echo $util - ok
        fi
done
