#! /bin/bash

[ -v MCEDITOR_INC_sounds_play ] || {
    [ "$MCEDITOR_dbgl" -ge 2 ] && echo '(sounds) loaded'
    MCEDITOR_INC_sounds_play=1

    # Initialize mpv instance and set ipc server and pid
    # Usage: sounds_init <server>
    sounds_init() {
        local server="$1"

        # Start mpv with IPC server
        mpv --no-video --force-window=no --idle=no --input-terminal=no --quiet --input-ipc-server=@"$server"  &
        mpvPid=$!  # Save the PID of the mpv process
        mpvIpcServer="$server"

        echo "mpv initialized with IPC server: $mpvIpcServer, PID: $mpvPid"
    }

    # Query current playing music on the given mpv server
    # Usage: sounds_query <server>
    sounds_query() {
        local server="$1"

        # Query mpv's current playlist and extract playing tracks (assuming ipc connection is available)
        response=$(echo '{"command":["get_property","playlist"]}' | socat - UNIX-CONNECT:@$server)

        # If there are tracks, filter and list them using jq
        track_list=$(echo "$response" | jq -r '.[] | select(.filename) | .filename')

        if [ -z "$track_list" ]; then
            echo "No music is playing."
        else
            echo "$track_list"
        fi
    }

    # Stop all currently playing music on the given mpv server
    # Usage: sounds_clear <server>
    sounds_clear() {
        local server="$1"

        # Send command to stop all music
        echo '{"command":["stop"]}' | socat - UNIX-CONNECT:@$server
        echo "All sounds stopped."
    }

    # Play a new music file with the given volume and pitch
    # Usage: sounds_play <server> <file> <volume> <pitch>
    sounds_play() {
        local server="$1"
        local file="$2"
        local volume="$3"
        local pitch="$4"

        # Play the specified file with given parameters
        echo '{"command":["loadfile", "'"$file"'", "append-play"]}' | socat - UNIX-CONNECT:@$server
        echo '{"command":["set_property", "volume", '"$volume"']}' | socat - UNIX-CONNECT:@$server
        echo '{"command":["set_property", "pitch", '"$pitch"']}' | socat - UNIX-CONNECT:@$server
        echo "Playing $file with volume $volume and pitch $pitch."
    }

    # Stop a specific music file from playing
    # Usage: sounds_stop <server> <file>
    sounds_stop() {
        local server="$1"
        local file="$2"

        # First, find the playlist item corresponding to the file
        response=$(echo '{"command":["get_property","playlist"]}' | socat - UNIX-CONNECT:@$server)
        
        # Find track ID using jq
        track_id=$(echo "$response" | jq -r '.[] | select(.filename == "'"$file"'") | .id')

        if [ "$track_id" != "null" ]; then
            echo '{"command":["playlist-remove", '"$track_id"']}' | socat - UNIX-CONNECT:@$server
            echo "Stopped $file."
        else
            echo "$file is not playing."
        fi
    }

    # End the mpv instance and clean up
    # Usage: sounds_end
    sounds_end() {
        if [ -z "$mpvPid" ]; then
            echo "No mpv process found."
            return 1
        fi

        # Attempt to stop mpv gracefully
        echo '{"command":["quit"]}' | socat - UNIX-CONNECT:@$mpvIpcServer >&2 || {
            # If it fails (stderr logs), attempt to kill the process gracefully
            if kill -0 "$mpvPid" 2>/dev/null; then
                kill -s SIGINT "$mpvPid"
                echo "mpv process $mpvPid stopped."
            else
                echo "mpv process $mpvPid not found."
            fi
        }
    }

}

