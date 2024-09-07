# Configuration — Manually replace these values 
$CriticalFiles = @("C:\Windows\System32\kernel32.dll", "C:\Windows\System32\ntdll.dll")
$AlertEmail = "admin@example.com"
$LogPath = "C:\Logs\SecurityMonitoring"
$HashBaselineFile = "$LogPath\HashBaseline.txt"
$ReportFile = "$LogPath\SecurityReport.txt"
$NetworkInterfaces = Get-NetAdapter | ForEach-Object { $_.Name }

# Ensure log directory exists
if (-not (Test-Path $LogPath)) {
    New-Item -Path $LogPath -ItemType Directory
}

# Function to generate file hashes
function Get-FileHashBaseline {
    foreach ($file in $CriticalFiles) {
        $hash = Get-FileHash $file -Algorithm SHA256
        "$($hash.Hash) $($hash.Path)" | Out-File -Append -FilePath $HashBaselineFile
    }
}

# Function to check for unauthorized file changes
function Check-FileIntegrity {
    $currentHashes = @()
    foreach ($file in $CriticalFiles) {
        $hash = Get-FileHash $file -Algorithm SHA256
        $currentHashes += "$($hash.Hash) $($hash.Path)"
    }
    $baselineHashes = Get-Content $HashBaselineFile
    if ($currentHashes -join "`n" -ne $baselineHashes -join "`n") {
        $message = "Unauthorized file changes detected!"
        Write-Output $message
        Send-Alert $message
    }
}

# Function to monitor disk usage
function Monitor-DiskUsage {
    $disks = Get-PSDrive -PSProvider FileSystem
    foreach ($disk in $disks) {
        $usage = [math]::Round(($disk.Used / ($disk.Used + $disk.Free)) * 100, 2)
        "$($disk.Name): $usage% used" | Out-File -Append -FilePath $ReportFile
        if ($usage -gt 90) {
            Send-Alert "Disk usage critical: $($disk.Name) is $usage% full."
        }
    }
}

# Function to monitor network activity
function Monitor-NetworkActivity {
    foreach ($interface in $NetworkInterfaces) {
        $networkStats = Get-NetAdapterStatistics -Name $interface
        "$interface - Received: $($networkStats.ReceivedBytes) bytes, Sent: $($networkStats.SentBytes) bytes" | Out-File -Append -FilePath $ReportFile
    }
}

# Function to monitor security events
function Monitor-SecurityEvents {
    $events = Get-WinEvent -FilterHashtable @{LogName='Security'; ID=4625,4672,4673} -MaxEvents 100
    foreach ($event in $events) {
        $event | Out-File -Append -FilePath $ReportFile
        if ($event.Id -eq 4625) {
            Send-Alert "Failed login attempt detected: $($event.Message)"
        } elseif ($event.Id -eq 4672) {
            Send-Alert "Privilege escalation detected: $($event.Message)"
        }
    }
}

# Function to check patch compliance
function Check-PatchCompliance {
    $updates = Get-WindowsUpdate -IsInstalled $false
    foreach ($update in $updates) {
        "Pending Update: $($update.Title)" | Out-File -Append -FilePath $ReportFile
    }
}

# Function to send alert emails
function Send-Alert($message) {
    Send-MailMessage -To $AlertEmail -From "monitoring@example.com" -Subject "Security Alert" -Body $message -SmtpServer "smtp.example.com"
}

# Main execution
# Generate file hash baseline if it doesn't exist
if (-not (Test-Path $HashBaselineFile)) {
    Get-FileHashBaseline
}

# Perform monitoring tasks
Monitor-DiskUsage
Monitor-NetworkActivity
Monitor-SecurityEvents
Check-FileIntegrity
Check-PatchCompliance

# Send the daily report
$reportContent = Get-Content $ReportFile -Raw
Send-MailMessage -To $AlertEmail -From "monitoring@example.com" -Subject "Daily Security Report" -Body $reportContent -SmtpServer "smtp.example.com"

# Clean up the report file for the next run
if (Test-Path $ReportFile) {
    Clear-Content $ReportFile
}
