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
    fix_start_seconds=$(date +%s)

    echo "Writing file ./${recording}"

    # In case of large (e.g .flac) audio streams it's possible that your hear no playback.
    # You can either increase wait_seconds to 4 or just restart the playback manually by entering 'r' after few seconds.
    local wait_seconds=1
    sleep $wait_seconds

    restarting_playback

    playback_status="Direct playback."
}

function restarting_playback {

    stop_playback_job

    if [ -n "${recording}" ]; then
        echo -n "Starting playback.. "
        screen -D -m -S my-vlc-server cvlc -I rc "${recording}" &
        job_cvlc_id=$!
        is_playing=true
        start_seconds=$(date +%s)
        echo OK
    fi
}

function get_input_from_user {
    calculate_next_station_index
    local next_number=$(( $next_index + 1 ))
    echo -n "Enter command key or station number ($next_number).. "
    read -r input
    user_input=$input
}

function calculate_next_station_index {
    if [ $job_wget_id -lt 0 ]; then
        next_index=0
    else
        local possible_next_index=$(( $station_index + 1 ))
        if [ $possible_next_index -ge ${#url[@]} ]; then
            next_index=0
        else
            next_index=$possible_next_index
        fi
    fi
}

function execute_command {
    if [[ $user_input == [qQ] ]]; then
        quit
    elif [[ $user_input == [rR] ]]; then
        restarting_playback
        playback_status="Playback was restarted and is delayed."
    elif [[ $user_input == [pP] ]]; then
        toggle_pause
    elif [[ $user_input =~ ^[wW]+$ ]]; then
        # TODO check what happens if pause is active and user wants to skip to past
        seek_playback "$user_input"
    elif [[ $user_input =~ ^\++$ ]]; then
        # number of plus characters -> steps
        local steps=${#input}
        screen -S my-vlc-server -p 0 -X stuff "volup ${steps}^M"
    elif [[ $user_input =~ ^-+$ ]]; then
        # number of minus characters -> steps
        local steps=${#input}
        screen -S my-vlc-server -p 0 -X stuff "voldown ${steps}^M"
    elif [[ $user_input == [bB] ]]; then
        local si=$station_index
        station_index=$previous_station_index
        previous_station_index=$si
        record_and_play
    elif [[ $user_input =~ ^[0-9]+$ ]]; then
        previous_station_index=$station_index
        station_index=$(( $user_input - 1))
        record_and_play
    else
        previous_station_index=$station_index
        station_index=$next_index
        record_and_play
    fi
}

function toggle_pause {
    screen -S my-vlc-server -p 0 -X stuff "pause^M"
    if $is_playing; then
        echo "PAUSE! -> Enter p again to go on with playback"
        is_playing=false
        playback_status="Playback is paused."
    else
        is_playing=true
        playback_status=$DELAYED_PLAYBACK
    fi
}

function seek_playback {
    local seconds=15
    local input=$1
    # number of characters -> step
    local step=$(( ${#input} * $seconds ))
    local current_date=$(date +%s)
    local elapsed_seconds=$(( $current_date - $start_seconds ))
    local seek_value=$(( $elapsed_seconds - $step ))
    if [ $seek_value -lt 0 ]; then
        seek_value=0
    fi
    start_seconds=$(( $start_seconds + $step ))
    if [ $start_seconds -gt "$current_date" ]; then
        start_seconds=$current_date
    fi
    screen -S my-vlc-server -p 0 -X stuff "seek ${seek_value}^M"
    playback_status=$DELAYED_PLAYBACK
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
    echo "RIP-AND-DIRECT-PLAYBACK  ***************************************** (C) TS CUSTER"
    echo
    echo "p) Pause playback"
    echo "r) Restart playback"
    echo "b) Select previous station"
    echo "w) Rewind 15 seconds"
    echo "+) Volume up"
    echo "-) Volume down"
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

function print_status {
    echo "SELECTED:  $(get_station_number)) ${station[station_index]}"
    local file_size=$(stat --printf="%s" "$recording")
    echo "Current size of \"$recording\": $file_size"
    echo "$playback_status"
}


##################### START #########################

! which tr > /dev/null && echo tr must be installed. && exit 1
! which wget > /dev/null && echo wget must be installed. && exit 1
! which screen > /dev/null && echo screen must be installed. && exit 1
! which vlc > /dev/null && echo vlc must be installed. && exit 1

script_name=$(basename "$0")

if [ ${#} -lt 1 ]; then
    echo "Usage: ${script_name} <internet radios file>"
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
old_file_size=0

DELAYED_PLAYBACK="Delayed playback."

init_stations

clear
print_commands_and_stations
echo

trap quit SIGINT

station_index=0
previous_station_index=0
while get_input_from_user; do
    execute_command
    clear
    print_commands_and_stations
    echo
    print_status
    echo
done

