#!/bin/bash

# Function to check disk space
check_disk_space() {
  echo "Checking disk space..."
  df -h 
  echo
}

# Function to check memory usage
check_memory_usage() {
 echo "Checking memory usage..."
  
  free_mem=$(cat /proc/meminfo | grep MemFree | awk '{print $2}')
  total_mem=$(cat /proc/meminfo | grep MemTotal | awk '{print $2}')

  mem_usage=$((100 * (total_mem - free_mem) / total_mem))

  echo "Free memory: $free_mem kB "
  echo "Used memory: $((total_mem - free_mem)) kB from $total_mem kB , (${mem_usage}%)"
  echo
  
}

check_virtual_memory_usage() {
  echo "Virtual memory usage:"

  vm_total=$(grep VmallocTotal /proc/meminfo | awk '{print $2}')
  vm_used=$(grep VmallocUsed /proc/meminfo | awk '{print $2}')
  
  if [ "$vm_total" -eq 0 ]; then
    echo "No Virtual memory available."
  else
    vm_free=$((vm_total - vm_used))
    vm_usage=$((100 * vm_used / vm_total))


    echo "Virtual memory available: $vm_free kB"
    echo "Virtual memory used: $vm_used kB of $vm_total ($vm_usage%)"
  fi
  echo
}

check_swap_usage() {
  echo "Swap usage:"

  swap_total=$(grep SwapTotal /proc/meminfo | awk '{print $2}')
  swap_free=$(grep SwapFree /proc/meminfo | awk '{print $2}')

  if [ "$swap_total" -eq 0 ]; then
    echo "No swap space available."
  else
    swap_used=$((swap_total - swap_free))
    swap_usage=$((100 * swap_used / swap_total))

    echo "Free swap: $swap_free kB"
    echo "Used swap: $swap_used from $swap_total kB ($swap_usage%)"
    echo
    
  fi
    echo
}

# Function to check running services
check_running_services() {
  echo "Checking running services..."

  # Check if the systemctl command is available (used in most modern Linux distributions)
  if command -v systemctl &> /dev/null; then
    systemctl list-units --type=service --state=running
  else
    echo "Neither systemctl nor service command is available on this system."
  fi
}

# Function to check for recent system updates
check_system_updates() {
  echo "Checking for recent system updates..."
  local log_file="/var/log/apt/history.log"

  if [ -f "$log_file" ]; then
    echo "Displaying the last 10 entries from $log_file:"
    tail -n 10 "$log_file"
  else
    echo "Log file $log_file does not exist."
  fi
  echo
}

# Function to generate a health report
generate_report() {
  echo "Generating health report..."
  report="system_health_report.txt"
  echo "System Health Report - $(date)" > $report
  echo "" >> $report
  echo "----------------------------------------" >> $report
  echo "Disk Space Usage:" >> $report
  check_disk_space >> $report
  echo "" >> $report
  echo "----------------------------------------" >> $report
  echo "Memory Usage:" >> $report
  check_memory_usage >> $report
  check_virtual_memory_usage >> $report
  check_swap_usage >> $report
  echo "----------------------------------------" >> $report
  echo "Running Services:" >> $report
  check_running_services >> $report
  echo "" >> $report
  echo "----------------------------------------" >> $report
  echo "System Updates:" >> $report
  check_system_updates >> $report
  echo "the health report is ready."
  echo
}

# Main function
main() {
  while true; do
    echo "Choose the check you want to perform:"
    echo "1. Check Disk Space"
    echo "2. Check Memory Usage"
    echo "3. Check Running Services"
    echo "4. Check System Updates"
    echo "5. Check All the system"
    echo "6. Generate Full Health Report"
    echo "7. Exit"
    read -p "Enter your choice [1-7]: " choice

    case $choice in
      1) 
         echo "-----------------Check Disk Space---------------------"
         check_disk_space ;;
      2) 
         echo "-----------------Check Memory Usage---------------------"
         check_memory_usage
	     check_virtual_memory_usage
	     check_swap_usage ;;
      3) 
         echo "-----------------Check Running Services---------------------"
         check_running_services ;;
      4) 
         echo "-----------------Check System Updates---------------------"
         check_system_updates ;;
      5) 
         echo "------------Check All the system----------------"
         check_disk_space
         check_memory_usage
         check_virtual_memory_usage
	     check_swap_usage
         check_running_services
         check_system_updates ;;
      6) 
         echo "------------Generate Full Health Report----------------"
         generate_report ;;
      7) echo "Exiting."; exit 0 ;;
      *) echo "Invalid choice. Please select a number between 1 and 6." ;;
    esac
  done
}

# Run the main function
main
