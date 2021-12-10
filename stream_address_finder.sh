#!/bin/bash


function download_playlist {
    mkdir -p tmp_stream_address_finder
    cd tmp_stream_address_finder
    /bin/rm -f $playlist
    wget -q -O $playlist $input
}

function is_beginning_with_http {
    local line=$1
    [[ $line == http* ]] || [[ $line == HTTP* ]]
}

function get_first_http_line_of_playlist {

    # This adds \n at the end of the file only if it doesn’t already end with a newline.
    # See https://unix.stackexchange.com/questions/31947/how-to-add-a-newline-to-the-end-of-a-file
    sed -i -e '$a\' $playlist
    # -> necessary with http://www.dradio.de/streaming/dkultur.m3u !

    local line
    while read line; do        
        is_beginning_with_http $line && echo $line && return
    done < $playlist
    # no http found!
    echo
}

function find_stream_address {
    if [[ ${input} != *.${playlist_suffix} ]]; then
        echo $input
    else 
        if download_playlist; then
            echo $(get_first_http_line_of_playlist)
            /bin/rm -f $playlist
        else 
            echo
        fi
    fi
}

###########################################################

if [ ! ${#} -eq 1 ]; then
    echo Usage: stream_address_finder.sh URL
    exit 1
fi

input=$1
playlist_suffix=m3u
playlist="playlist.${playlist_suffix}"
echo $(find_stream_address)
