#!/bin/bash


function download_playlist {
    mkdir -p tmp_stream_address_finder
    cd tmp_stream_address_finder
    /bin/rm -f $playlist
    wget -q -O $playlist $input
}

function is_beginning_with_http {
    [[ $1 == [hH][tT][tT][pP]* ]]
}

function get_first_http_line_of_playlist {

    # Modify the playlist slightly
    sed -i -f ../playlist_edit.sed $playlist

    local line
    while read line; do        
        is_beginning_with_http $line && echo $line && return
    done < $playlist
    # no http found!
    echo
}

function find_stream_address {

    local playlist_suffix
    playlist=""
    for playlist_suffix in "${playlist_suffixes[@]}"; do
        if [[ ${input} == *.${playlist_suffix} ]]; then
            playlist="playlist.${playlist_suffix}"
            break        
        fi
    done

    if [[ ${playlist} == "" ]]; then
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
    echo Usage: $0 URL
    exit 1
fi

# Supported playlist types (suffixes)
declare -a playlist_suffixes=(m3u pls)

input=$1
echo $(find_stream_address)
