# Function to generate disk space report
function Get-DiskSpaceReport {
    $diskReport = Get-WmiObject Win32_LogicalDisk | Where-Object {$_.DriveType -eq 3} | Select-Object DeviceID, 
        @{Name="Size(GB)";Expression={"{0:N2}" -f ($_.Size/1GB)}},
        @{Name="FreeSpace(GB)";Expression={"{0:N2}" -f ($_.FreeSpace/1GB)}},
        @{Name="UsedSpace(GB)";Expression={"{0:N2}" -f (($_.Size - $_.FreeSpace)/1GB)}},
        @{Name="FreeSpace(%)";Expression={"{0:P2}" -f ($_.FreeSpace / $_.Size)}}
    
    Write-Output "Disk Space Report:"
    $diskReport | Format-Table -AutoSize
}

# Function to generate network utilization report
function Get-NetworkUtilizationReport {
    $networkReport = Get-Counter -Counter "\Network Interface(*)\Bytes Total/sec" | 
        Select-Object -ExpandProperty CounterSamples | 
        Where-Object {$_.InstanceName -notlike "*isatap*"} | 
        Select-Object InstanceName, 
            @{Name="NetworkUtilization(Mbps)";Expression={"{0:N2}" -f ($_.CookedValue/1e6)}}
    
    Write-Output "Network Utilization Report:"
    $networkReport | Format-Table -AutoSize
}

# Function to check event logs
function Check-EventLogs {
    $eventLogs = Get-EventLog -LogName "System" -EntryType "Error", "Warning" -Newest 10
    
    Write-Output "Event Log Check:"
    $eventLogs | Format-Table -Property TimeGenerated, EntryType, Source, Message -AutoSize
}

# Main script
Write-Output

# Generate disk space report
Get-DiskSpaceReport

# Generate network utilization report
Get-NetworkUtilizationReport

# Check event logs
Check-EventLogs
