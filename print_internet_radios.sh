#!/bin/bash


function is_beginning_with_number_sign {
    [[ $1 == [#]* ]]
}

function is_beginning_with_http {
    [[ $1 == [hH][tT][tT][pP]* ]]
}

function get_suffix_by_last_element {
    local last_element=""
    local element
    for element in $1; do
        last_element=$element
    done
    local suffix=$(echo "$last_element" | tr -d '()')
    if [[ $suffix == [mM][pP][3] ]] || [[ $suffix == [aA][aA][cC] ]] || [[ $suffix == [oO][gG][gG] ]] || [[ $suffix == [fF][lL][aA][cC] ]]; then
        echo "$suffix" | tr '[:upper:]' '[:lower:]'
    else
        echo
    fi
}

function find_suffix_in_url {
    local url=$1
    if [[ $url == *[mM][pP][3]* ]]; then
        echo mp3
    elif [[ $url == *[aA][aA][cC]* ]]; then
        echo aac
    elif [[ $url == *[oO][gG][gG]* ]]; then
        echo ogg
    elif [[ $url == *[fF][lL][aA][cC]* ]]; then
        echo flac
    else
        echo audio
    fi
}

################### START ##################

input_file=$1
suffix=""
while read -r line; do
    if [[ -n "$line" ]] && ! is_beginning_with_number_sign "$line" ; then
        echo "$line"
        if ! is_beginning_with_http "$line"; then                        
            suffix=$(get_suffix_by_last_element "$line")
        else
            if [ -z "$suffix" ]; then
                suffix=$(find_suffix_in_url "$line")
            fi
            echo "$suffix"
        fi
    else
        suffix=""
    fi
done < "$input_file"
