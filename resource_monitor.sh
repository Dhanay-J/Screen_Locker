#!/bin/bash

# Package name of the screen locker app
PACKAGE="com.example.screen_locker"

# Function to check if app is running
check_app() {
    running=$(adb.exe shell "ps -A | grep $PACKAGE")
    if [ -n "$running" ]; then
        return 0  # App is running
    else
        return 1  # App is not running
    fi
}

# Function to get process ID
get_pid() {
    pid=$(adb.exe shell "ps -A | grep $PACKAGE | tr -s ' ' | cut -d ' ' -f 2")
    echo $pid
}

# Function to print resource usage
print_resources() {
    pid=$(get_pid)
    if [ -n "$pid" ]; then
        echo "Resource Usage for $PACKAGE (PID: $pid):"
        echo "----------------------------------------"
        
        # CPU usage
        echo "CPU Usage:"
        adb.exe shell "top -n 1 -p $pid | grep $PACKAGE"
        
        # Memory usage
        echo -e "\nMemory Usage:"
        adb.exe shell "dumpsys meminfo $pid | grep -A 1 'TOTAL'"
        
        # Thread count
        echo -e "\nThread Count:"
        adb.exe shell "ps -T | grep $pid | wc -l"
        
        # Battery usage
        echo -e "\nBattery Usage:"
        adb.exe shell "dumpsys batterystats --charged $PACKAGE | grep -A 2 'Statistics since last charge'"
    else
        echo "null"
    fi
}

while [[ 1 ]]; do
    # Main execution
    if check_app; then
        print_resources
    fi
done