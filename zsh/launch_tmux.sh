#!/bin/zsh

# Define an array with elements
elements=("acer" "work" "plan")

# Check if the script is running inside a tmux session
if [[ -n "$TMUX" ]]; then
    echo "HELLO D"
    exit 0
fi

# Check for running tmux sessions
for element in "${elements[@]}"; do
    if tmux has-session -t "$element" 2>/dev/null; then
        # Get the creation time of the tmux session
        creation_time=$(tmux show-options -g | grep -A 1 "^session: $element" | tail -n 1 | awk '{print $2}')
        
        # Calculate the time difference in seconds
        current_time=$(date +%s)
        session_time=$(date -d "$creation_time" +%s)
        time_diff=$((current_time - session_time))
        
        # Check if the session was created in less than a minute (60 seconds)
        if [[ "$time_diff" -lt 60 ]]; then
            echo "Tmux session '$element' is running and was created less than a minute ago."
            echo "Attaching to session '$element'."
            tmux attach-session -t "$element"
            exit 0
        else
            echo "Tmux session '$element' is running."
            echo "Created at: $creation_time"
        fi
    else
        echo "Tmux session '$element' is not running."
        # Create a new tmux session with the name
        echo "Creating a new tmux session '$element' and attaching to it."
        tmux new-session -s "$element" -d
        tmux attach-session -t "$element"
        exit 0
    fi
done

clear
echo "ALL sessions Full"
