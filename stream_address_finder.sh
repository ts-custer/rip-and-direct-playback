#!/bin/bash


function download_playlist {
    rm -f "$playlist"
    wget -q -O "$playlist" "$input"
}

function is_beginning_with_http {
    [[ $1 == [hH][tT][tT][pP]* ]]
}

function get_first_http_line_of_playlist {
    local line
    old_ifs=$IFS
    IFS=$'\n'
    # shellcheck disable=SC2013
    # shellcheck disable=SC2094
    for line in $(cat "$playlist"); do
        line=$(replace_all_after_file "$line")
        is_beginning_with_http "$line" && IFS=$old_ifs && echo "$line" && return
    done < "$playlist"
    IFS=$old_ifs
    # no http found!
    echo
}

function replace_all_after_file {
  local line=$1
  # e.g. "File1="
  local search="[Ff][Ii][Ll][Ee][0-9]*="
  local result="${line#*$search}"
  if [ -n "$result" ]; then
    echo "$result"
  else
    echo "$line"
  fi
}

function find_stream_address {

    local playlist_suffix
    playlist=""
    for playlist_suffix in "${playlist_suffixes[@]}"; do
        if [[ ${input} == *.${playlist_suffix} ]]; then
            local filename=$(basename "${input}")
            playlist=$(mktemp -t XXXXXX_"${filename}")
            break        
        fi
    done

    if [ -z "$playlist" ]; then
        echo "$input"
    else
        if download_playlist; then
            get_first_http_line_of_playlist
            rm -f "$playlist"
        else 
            echo
        fi
    fi
}

###########################################################

if [ ! ${#} -eq 1 ]; then
    echo Usage: "$0" URL
    exit 1
fi

# Supported playlist types (suffixes)
declare -a playlist_suffixes=(m3u pls)

input=$1
find_stream_address
