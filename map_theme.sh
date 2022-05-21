#!/bin/bash

ALL_FOLDERS='*/'
DEFAULT_DIRECTORY='templates/'
TARGET_DIRECTORY=${1:-$DEFAULT_DIRECTORY}
OUTFILE_NAME=${2:-'theme_code_map.txt'}

declare -a all_files=()
declare -a target_files=()
declare -a used_files=()
declare -a unused_files=()

echo "All Folders:"
for FOLDER in $ALL_FOLDERS; 
do
    echo "$FOLDER"
    for FILE in $FOLDER*;
    do
        all_files+=("$FILE")
    done
done

CUSTOMER_DIRECTORY="templates/customers/"
echo "$CUSTOMER_DIRECTORY"
for FILE in $CUSTOMER_DIRECTORY*;
do
    all_files+=("$FILE")
done
echo ""

echo "Target Directories:"
for FOLDER in $TARGET_DIRECTORY; 
do
    echo "$FOLDER"
    for FILE in $FOLDER*;
    do
        target_files+=("$FILE")
    done
done
echo ""

trace_file() {
    echo ""

    #Get parent file name
    local parent_file_name=$1
    local spaces=$2

	#echo "Running trace_file() on $parent_file_name"

    #Find children file references in liquid "include" tags:

    #TODO: Save egrep output as a single variable (better performance)

    #Look for file names between single quotes
    children_files_sq=($(egrep -o "\{%[-]* (include|render) [^ ]*(,|\s)" $parent_file_name | grep -o "'.*'" | sed "s/'//g"))

    #Look for file names between double quotes
    children_files_dq=($(egrep -o "\{%[-]* (include|render) [^ ]*(,|\s)" $parent_file_name | grep -o "'.*'" | sed "s/'//g"))

    #Look for section children files
    children_files_sec=($(egrep -o "\{% section [^ ]*\s" $parent_file_name | grep -o "'.*'" | sed "s/'//g"))

    #Concatenate arrays
    children_files=("${children_files_sq[@]}" "${children_files_dq[@]}" "${children_files_sec[@]}")
    children_files_len=${#children_files[@]}

    #Get sorted, unique file values only
    unique_children_files=($(echo "${children_files[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
    unique_children_files_len=${#unique_children_files[@]}

	#echo -e "\nParent File: $parent_file_name"
    #echo -e "\nUnique Child Files:"
    #for unique_child_file in "${unique_children_files[@]}"
    #do
    #    echo "$unique_child_file"
    #done
    #echo ""

	#echo "Unique Child File Length: $unique_children_files_len"


    echo -e "$spaces    |___$parent_file_name"
    #echo "parent file name: $parent_file_name"
    if (($unique_children_files_len > 0)); then
        for unique_child_file in "${unique_children_files[@]}"
        do
            #echo -e "\nMatching files for unique child file:"
            matching_files=($(printf -- '%s\n' "${all_files[@]}" | egrep ".*/$unique_child_file"))
            declare -a non_circular_matching_files=()
            for matching_child_file_name in "${matching_files[@]}"
            do
                #echo "$matching_child_file_name"
                if [ "$matching_child_file_name" != "$parent_file_name" ]; then
					#echo "$matching_child_file_name does not equal $parent_file_name"
                    non_circular_matching_files+=("$matching_child_file_name")
                    used_files+=("$matching_child_file_name")
				#else
					#echo "$child file matches parent, would create loop"
                fi
            done

            #echo -e "\nNon-circular matching files for unique child file:"
            for non_circular_matching_file in "${non_circular_matching_files[@]}"
            do
                #echo "$non_circular_matching_file"
                trace_file $non_circular_matching_file "    |   $spaces"
            done
            #echo ""
        done
	#else
		#echo "Returning to parent..."
    fi
}

map_theme() {
	echo "Analyzing Files..."
	for file_name in "${target_files[@]}"
	do
		trace_file $file_name ""
	done
	echo -e "\nDone tracing files!\n"

    #TODO: Implement this better
	#echo "Checking for unused files:"
	#for file_name in "${all_files[@]}"
	#do
	#	if printf '%s\0' "${used_files[@]}" | grep -Fxqz $file_name; then
	#		echo "File $file_name was used!"
	#	else
	#		echo "File $file_name was not used..."
	#		unused_files+=("$file_name")
	#	fi
	#done

	#echo -e "\nUnused files:"
	#for file_name in "${unused_files[@]}"
	#do
	#	echo "$file_name"
	#done
}

map_theme | tee $OUTFILE_NAME