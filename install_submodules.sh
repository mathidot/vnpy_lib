#!/bin/bash

# Loop through all subdirectories in the current directory
for dir in */; do
    # Check if it's actually a directory
    if [ -d "$dir" ]; then
        echo "Entering directory: $dir"
        # Change into the directory
        pushd "$dir" > /dev/null
        
        # Execute pip install .
        echo "Running pip install . in $dir"
        pip install .
        
        # Check if pip install was successful
        if [ $? -eq 0 ]; then
            echo "Successfully ran pip install . in $dir"
        else
            echo "Error: pip install . failed in $dir"
        fi
        
        # Change back to the original directory
        popd > /dev/null
        echo "Exited directory: $dir"
        echo "------------------------------------"
    fi
done

echo "Script finished."
