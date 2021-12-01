#!/bin/sh

mawk '
BEGIN {
    # get the command line argument for the cutting param
    # with default 9
    cut='"${1:-9}"';
}
{
    if (NR % 2 == 0) {
        print substr($0,cut,1000);
    } else {
        print $0;
}
}'