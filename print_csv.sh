#!/bin/bash

gawk '
BEGIN {
    FPAT = "([^,]+)|(\"[^\"]+\")"
}
{
    printf("%s\n", $1)
    printf("%s\n", $2)
    printf("%s\n", $3)
}
' $1
