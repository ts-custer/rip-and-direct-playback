#!/bin/bash

gawk '
BEGIN {
    FPAT = "([^,]+)|(\"[^\"]+\")"
    count=0
}
{
    printf("%s\n", $1)
    printf("%s\n", $2)
    printf("%s\n", $3)
    ++count
}
' $1
