#! /bin/bash

[ -v MCEDITOR_INC_optional_features ] || {

	[ "$MCEDITOR_dbgl" -ge 2 ] && echo '(optional_features) loaded'
	MCEDITOR_INC_optional_features=1

	# Create a new feature list (associative array)
	# create_feature_list <list>
	create_feature_list() {
		local name="$1"
		declare -gA "$name"
	}

	# Free a feature list
	# free_feature_list <list>
	free_feature_list() {
		local name="$1"
		unset "$name"
	}

	# Enable a feature with level
	# enable_feature <list> <id> <level>
	enable_feature() {
		local list="$1"
		local id="$2"
		local level="$3"

		# Reference the associative array by name
		declare -n features="$list"

		# Ensure the array exists
		declare -p features &>/dev/null || declare -gA "$list"

		features["$id"]="$level"
		echo "Feature $id for $mcide is enabled with level $level!" >&2
	}

	# Disable a feature
	# disable_feature <list> <id>
	disable_feature() {
		local list="$1"
		local id="$2"

		declare -n features="$list"
		unset 'features[$id]'
		echo "Feature $id for $mcide is disabled!" >&2
	}

	# Check if any feature has level >= minLevel
	# check_feature <list> <id> <minLevel>
	# Return:
	#   0 = condition satisfied
	#   1 = not satisfied
	check_feature() {
		local list="$1"
		local id="$2"
		local minLevel="$3"

		declare -n features="$list"
		local level="${features[$id]}"

		if (( level >= minLevel )); then
			return 0
		fi

		return 1
	}

}

