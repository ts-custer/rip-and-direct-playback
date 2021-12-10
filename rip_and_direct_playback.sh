#!/bin/bash

function init_stations {
    
    local line
    while read line; do                        
        local line_number=$(get_station_number)
        local j=0
        local ifs_old=${IFS}
        IFS=$','
        for detail in $line; do
            if [ $j -eq 0 ]; then
                station[$station_index]="$detail"
            elif [ $j -eq 1 ]; then
                suffix[$station_index]="$detail"
            elif [ $j -eq 2 ]; then
                url[$station_index]="$detail"
            else                
                echo "More than 2 commas in line $line_number of file \"$station_file\":"
                echo $line
                exit 1                
            fi
            j=$(( $j + 1 ))
        done
        IFS=${ifs_old}
        station_index=$line_number
    done < $station_file
}

function increment_station_index {

    next_index=$(( ${station_index} + 1 ))
    if [ $next_index -ge ${#url[@]} ] || [ $next_index -lt 0 ]; then
        station_index=0
    else 
        station_index=$next_index
    fi    
}

function get_station_number {
    echo $(( $station_index + 1 ))
}

function print_stations {
    echo
    local i
    for ((i=0; i < ${#url[@]}; i++)); do
        local number=$(( $i + 1 ))
        echo "$number) ${station[${i}]}"
    done
}

function record_and_play {

    # Terminate old recording job
    stop_recording_job

    echo
    echo "***** $(get_station_number)) ${station[station_index]} *****"    
    echo
    echo "Finding the real stream address:"
    echo -n "${url[${station_index}]} -> "
    local stream_address=$(./stream_address_finder.sh ${url[${station_index}]})
    echo $stream_address

    # Create filename for recording
    local now=$(date +"%Y-%m-%d_%H-%M-%S")
    local sfx=${suffix[${station_index}]}
    if [ -z $sfx ]; then
        sfx=audio
    fi
    recording="${recordings_folder}/${now} ${station[${station_index}]}.${sfx}"

    # Create recording folder if not exists
    mkdir -p "$recordings_folder"

    echo -n "Starting recording.. "
    wget -q -O "$recording" $stream_address &
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

    if [ ! -z "${recording}" ]; then
        echo -n "Starting playback.. "
        cvlc "${recording}" &
        job_cvlc_id=$!
        echo OK
        echo
        sleep 1
    fi
}

function selection {
    
    echo
    echo -n "Enter number of the station to record and play ($(get_station_number)).."
    read input

    if [[ $input == "q" ]] || [[ $input == "Q" ]]; then
        quit
    elif [[ $input == "s" ]] || [[ $input == "S" ]]; then
        print_stations
    elif [[ $input == "r" ]] || [[ $input == "R" ]]; then    
        restarting_playback
    else
        if [ ! -z $input ]; then
            station_index=$(( $input - 1))
        fi
        record_and_play
        increment_station_index        
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

###########################################################

# Initiate variables
station_file="internet_radios.csv"
recordings_folder=recordings
declare -a station
declare -a suffix
declare -a url
station_index=0
recording=""
job_wget_id=-1
job_cvlc_id=-1

init_stations

echo
echo "s) Print stations"
echo "r) Restarting playback"
echo "q) Quit"
print_stations

trap quit SIGINT

station_index=0
while true; do
    selection
done
