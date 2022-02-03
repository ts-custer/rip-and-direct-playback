#!/bin/bash


function init_stations {

    local tmp_station_file=.tmp_${station_file}
    /bin/rm -fr "${tmp_station_file}"
    ./print_internet_radios.sh "${station_file}" > "${tmp_station_file}"
   
    station_index=0
    local line
    local j=0
    while read -r line; do
        if [ $j -eq 0 ]; then
            station[$station_index]="$line"
            j=1
        elif [ $j -eq 1 ]; then
            url[$station_index]="$line"
            j=2
        elif [ $j -eq 2 ]; then
            suffix[$station_index]="$line"
            j=0
            station_index=$(( station_index + 1 ))
        fi
    done < "${tmp_station_file}"

    /bin/rm -fr "${tmp_station_file}"
}

function get_next_station_index {

    local next_index=$(( $1 + 1 ))
    if [ $next_index -ge ${#url[@]} ]; then
        echo 0
    else 
        echo $next_index
    fi    
}

function get_station_number {
    echo $(( $station_index + 1 ))
}

function record_and_play {

    # Terminate old recording job
    stop_recording_job

    echo
    echo
    echo "SELECTED:  $(get_station_number)) ${station[station_index]}"
    echo
    echo "Finding the real stream address:"
    echo -n "${url[${station_index}]} -> "
    local stream_address=$(./stream_address_finder.sh "${url[${station_index}]}")
    echo "$stream_address"

    # Create filename for recording
    local now=$(date +"%Y-%m-%d_%H-%M-%S")
    local sfx=${suffix[${station_index}]}
    if [ -z "$sfx" ]; then
        sfx=audio
    fi
    recording="${recordings_folder}/${now} ${station[${station_index}]}.${sfx}"

    # Create recording folder if not exists
    mkdir -p "$recordings_folder"

    echo -n "Starting recording.. "
    wget -q -O "$recording" "$stream_address" &
    job_wget_id=$!
    echo OK

    echo "Writing file ./${recording}"

    # In case of large (e.g .flac) audio streams it's possible that your hear no playback.
    # You can either increase wait_seconds to 4 or just restart the playback manually by entering 'r' after few seconds.
    local wait_seconds=1
    sleep $wait_seconds

    restarting_playback
}

function restarting_playback {

    stop_playback_job

    if [ -n "${recording}" ]; then
        echo -n "Starting playback.. "
        screen -D -m -S my-vlc-server cvlc -I rc "${recording}" &
        job_cvlc_id=$!
        is_playing=true
        echo OK
        sleep 1
    fi
}

function selection {

    local next_index
    local next_number
    if [ $job_wget_id -lt 0 ]; then
        next_index=0
        next_number=1
    else
        next_index=$(get_next_station_index $station_index)
        next_number=$(( $next_index + 1 ))
    fi

    echo
    echo -n "Enter command key or station number ($next_number).."
    read -r input

    if [[ $input == [qQ] ]]; then
        quit
#    elif [[ $input == "s" ]] || [[ $input == "S" ]]; then
#        clear
#        print_stations
    elif [[ $input == [rR] ]]; then
        restarting_playback
    elif [[ $input == [pP] ]]; then
        screen -S my-vlc-server -p 0 -X stuff "pause^M"
        if $is_playing; then
          echo "PAUSE! -> Enter p again to go on with playback"
          is_playing=false
        else
          is_playing=true
        fi
    elif [[ $input == "-" ]]; then
        print_commands_and_stations
        local si=$station_index
        station_index=$previous_station_index
        previous_station_index=$si
        record_and_play
    elif [[ $input != "" ]]; then
        print_commands_and_stations
        previous_station_index=$station_index
        station_index=$(( $input - 1))
        record_and_play
    else
        print_commands_and_stations
        previous_station_index=$station_index
        station_index=$next_index
        record_and_play
    fi
}

function stop_recording_job {
    if [ $job_wget_id -gt -1 ]; then
        kill $job_wget_id 2> /dev/null
    fi
}

function stop_playback_job {
    if [ $job_cvlc_id -gt -1 ]; then
        kill $job_cvlc_id 2> /dev/null
    fi
}

function quit {
    stop_playback_job
    stop_recording_job
    echo
    echo "Goodbye."
    exit 0
}

function print_commands_and_stations {
    clear
    echo "RIP-AND-DIRECT-PLAYBACK  ***************************************** (C) TS CUSTER"
    echo
#    echo "s) Print stations"
    echo "p) Pause playback"
    echo "r) Restart playback"
    echo "-) Select previous station"
    echo "q) Quit"
    echo
    print_stations
}

function print_stations {
    local i
    for ((i=0; i < ${#url[@]}; i++)); do
        local number=$(( $i + 1 ))
        echo "$number) ${station[${i}]}"
    done
}

##################### START #########################

! which tr > /dev/null && echo tr must be installed. && exit 1
! which sed > /dev/null && echo sed must be installed. && exit 1
! which wget > /dev/null && echo wget must be installed. && exit 1
! which screen > /dev/null && echo screen must be installed. && exit 1
! which vlc > /dev/null && echo vlc must be installed. && exit 1

if [ ${#} -lt 1 ]; then
    echo "Usage: ${0} <internet radios file>"
    exit 1
fi

# Initiate variables
station_file=$1
recordings_folder=recordings
declare -a station
declare -a url
declare -a suffix
station_index=0
recording=""
job_wget_id=-1
job_cvlc_id=-1

init_stations

print_commands_and_stations

trap quit SIGINT

station_index=0
previous_station_index=0
while true; do    
    selection
done
