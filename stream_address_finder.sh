#!/bin/bash


function download_playlist {
    /bin/rm -f $playlist
    wget -q -O $playlist $input
}

function is_beginning_with_http {
    [[ $1 == [hH][tT][tT][pP]* ]]
}

function get_first_http_line_of_playlist {

    # Remove leading "File..=" of each line (necessary for .pls playlists)
    sed -i 's/^[Ff][Ii][Ll][Ee][0-9]*[0-9]*=//' $playlist

    local line
    old_ifs=$IFS
    IFS=$'\n'
    for line in $(cat $playlist); do
        is_beginning_with_http $line && IFS=$old_ifs && echo $line && return
    done < $playlist
    IFS=$old_ifs
    # no http found!
    echo
}

function find_stream_address {

    local playlist_suffix
    playlist=""
    for playlist_suffix in "${playlist_suffixes[@]}"; do
        if [[ ${input} == *.${playlist_suffix} ]]; then
            playlist="tmp_stream_address_finder_playlist.${playlist_suffix}"
            break        
        fi
    done

    if [ -z ${playlist} ]; then
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
