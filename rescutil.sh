: "
rescutil

:: Background
CLI + Terminal-Based, Resolution Control Utility/Script that aids in simplifying resolution control. 
	- Main focus is on Resolution Management (screen size etc.)
	- powered primarily by xrandr

- Part of my Linux general utility suite of scripts : [linux-gen-utils](https://github.com/Thanatisia/linux-gen-utils)
	- Designed to be simple access via an all-in-one repository
		- Designed to work without reliance on dependencies (if possible)
- Comes with GUI Mode and Terminal-based parameters execution


:: Pre-Requisite

:: Usage
	./rescutil {params}

:: Options
	- CLI Menu
	- Terminal-Based	
"

: "
Variables
"

# "Constants"
all_monitors=$(xrandr | grep " connected " | awk '{ print $1 }')	# Get all monitors connected
number_of_monitors=$(xrandr | grep " connected " | awk '{ print NF }')	# Get total number of monitors connected; NF : Number of Fields in the current line (by default, a field is a word delimited by any amount of whitespace)

# --- Associative Arrays
declare -A OPTIONS=(
    [list-info]="-q"
    [set-output]="--output"
    [set-resolution]="--mode"
    [set-framerate]="--rate"
    [set-primary]="--primary"
    [position-left]="--left-of"
    [position-right]="--right-of"
)

declare -A pos_schema=(
    # Set Position of all monitors
    # [1] : 1st Monitor ... [n] : Nth Monitor
)

# Global Variables
output=""
width=0
height=0
resolution=""
framerate=0.0
primary_monitor=""

# --- Pre-processing

# Populate Positions
for i in $number_of_monitors; do
    # pos_schema[0|1|2|...n]=value
    pos_schema[$i]="${all_monitors[$i]}"
done

: "
Functions
"

get_output()
{
    # Local Variables
    res=""

    # Get User Input
    read -p "Please select an output: " res

    # Return result
    echo "$res"
}

get_width()
{
    : "
    Get Width of Monitor
    "
    # Local Variables
    res=""

    # Get User Input
    read -p "Resolution : Please indicate width of monitor (i.e. 1920): " res

    # Return result
    echo "$res"
}

get_height()
{
    : "
    Get Height of Monitor
    "
    # Local Variables
    res=""

    # Get User Input
    read -p "Resolution : Please indicate height of monitor (1080): " res

    # Return result
    echo "$res"
}

get_x_axis()
{
    : "
    Get X axis (Position) of Monitor
    "
    # Local Variables
    res=""

    # Get User Input
    read -p "Position : Please specify X-axis of monitor: " res

    # Return result
    echo "$res"
}

get_y_axis()
{
    : "
    Get Y axis (Position) of Monitor
    "
    # Local Variables
    res=""

    # Get User Input
    read -p "Position : Please specify Y-axis of monitor: " res

    # Return result
    echo "$res"
}

get_framerate()
{
    : "
    Get Framerate of Monitor
    "
    # Local Variables
    res=""

    # Get User Input
    read -p "Please indicate height of monitor (1080): " res

    # Return result
    echo "$res"
}

set_primary()
{
    : "
    Set output as primary
    "
    global primary_monitor
    target_monitor="$1"
    
    # Set monitor as primary
    primary_monitor=$target_monitor
}

set_pos_left()
{
    : "
    Set selected monitor on the left of target-monitor
    "
    global pos_schema
    selected_monitor="$1"
    target_monitor="$2"
    
    # Get position of [selected-monitor] and [target-monitor]
    sel_monitor_pos=-1
    target_monitor_pos=-1

    for monitor in "${!pos_schema[@]}"; do
	curr_monitor=${pos_schema[$monitor]}

	: "
	Get Position of [selected monitor] and [target monitor]
	"

	# Check if current monitor is [selected-monitor]
	if [[ "$curr_monitor" == "$selected_monitor" ]]; then
	    sel_monitor_pos=$monitor
	fi

	# Check if current monitor is [target_monitor]
	if [[ "$curr_monitor" == "$target_monitor" ]]; then
	    target_monitor_pos=$monitor
	fi

	# Escape case
	if [[ $sel_monitor_pos -gt -1 ]] && [[ $target_monitor_pos -gt -1 ]]; then
		# If [selected monitor position] is more than -1 (0,1,2...) AND
		# If [target monitor position] is more than -1
		break
	fi
    done

    # Get Monitor Detail on the left of [target-monitor]
    target_monitor_left_pos=$target_monitor_pos - 1			# Get Monitor Position number left of [target-monitor] (-1)
    target_monitor_left=${pos_schema[$target_monitor_left_pos]}		# Get Monitor left of [target-monitor]

    # Swap [selected-monitor] with monitor on the left of [target-monitor] 
    pos_schema[$target_monitor_left_pos]="$selected_monitor"
    pos_schema[$sel_monitor_pos]="$target_monitor_left"
}

set_pos_right()
{
    : "
    Set selected monitor on the right of target-monitor
    "
    global pos_schema
    selected_monitor="$1"
    target_monitor="$2"
    
    # Get position of [selected-monitor] and [target-monitor]
    sel_monitor_pos=-1
    target_monitor_pos=-1

    for monitor in "${!pos_schema[@]}"; do
	curr_monitor=${pos_schema[$monitor]}

	: "
	Get Position of [selected monitor] and [target monitor]
	"

	# Check if current monitor is [selected-monitor]
	if [[ "$curr_monitor" == "$selected_monitor" ]]; then
	    sel_monitor_pos=$monitor
	fi

	# Check if current monitor is [target_monitor]
	if [[ "$curr_monitor" == "$target_monitor" ]]; then
	    target_monitor_pos=$monitor
	fi

	# Escape case
	if [[ $sel_monitor_pos -gt -1 ]] && [[ $target_monitor_pos -gt -1 ]]; then
		# If [selected monitor position] is more than -1 (0,1,2...) AND
		# If [target monitor position] is more than -1
		break
	fi
    done

    # Get Monitor Detail on the right of [target-monitor]
    target_monitor_right_pos=$target_monitor_pos + 1			# Get Monitor Position number right of [target-monitor] (+1)
    target_monitor_right=${pos_schema[$target_monitor_right_pos]}	# Get Monitor right of [target-monitor]

    # Swap [selected-monitor] with monitor on the right of [target-monitor] 
    pos_schema[$target_monitor_right_pos]="$selected_monitor"
    pos_schema[$sel_monitor_pos]="$target_monitor_right"
}

swap_pos()
{
    : "
    Swap Position of Monitor
    "
    global pos_schema
    selected_monitor="$1"
    target_monitor="$2"
    
    # Get position of [selected-monitor] and [target-monitor]
    sel_monitor_pos=-1
    target_monitor_pos=-1

    for monitor in "${!pos_schema[@]}"; do
	curr_monitor=${pos_schema[$monitor]}

	# Check if current monitor is [selected-monitor]
	if [[ "$curr_monitor" == "$selected_monitor" ]]; then
	    sel_monitor_pos=$monitor
	fi

	# Check if current monitor is [target_monitor]
	if [[ "$curr_monitor" == "$target_monitor" ]]; then
	    target_monitor_pos=$monitor
	fi

	# Escape case
	if [[ $sel_monitor_pos -gt -1 ]] && [[ $target_monitor_pos -gt -1 ]]; then
		# If [selected monitor position] is more than -1 (0,1,2...) AND
		# If [target monitor position] is more than -1
		break
	fi
    done

    # Swap Position
    pos_schema[$sel_monitor_pos]="$selected_monitor"
    pos_schema[$target_monitor_pos]="$target_monitor"
}

gen_resolution()
{
    : "
    Generate Resolution from Width * Height
    "
    global resolution

    width=${1:-0}
    height=${2:-0}

    # Calculate Resolution
    resolution="$widthx$height"

    echo "$resolution"
}

menu()
{
	
}

init()
{
    : "
    Initialization
    "
}

main()
{
    # Get Command Line Arguments
    argv=$@
    argc="${#argv[@]}"

    # Body
    init
    menu
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	main "$@"
fi