#!/bin/sh
if [ -z $1 ];
then echo "No draft specified";
else mv $1 "_posts/$(date +%Y-%m-%d)-$(cut -d "/" -f 2 <<< $1)";
fi
