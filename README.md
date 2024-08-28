🛡️ Security-Focused System Monitoring PowerShell Script
Welcome to the PowerShell Script for Security-Focused System Monitoring! This script is intended to assist you in monitoring and maintaining the safety, security, and optimal condition of your Windows system. Critical system metrics, such as disk usage, network activity, and security events, are automatically monitored while it keeps an eye out for any covert unauthorized file changes. It will also notify you if your system patches are getting behind schedule. 📈🚨

🚀 What Does This Script Do?
Disk Usage Monitoring: Logs how much disk space is being used.
Network Activity Monitoring: Tracks network data on specified interfaces.
Security Events Monitoring: Logs failed login attempts and privilege escalations.
File Integrity Monitoring (FIM): Detects unauthorized changes to critical files using hash comparisons.
Patch Compliance: Generates reports on pending system updates.

🛠️ How to Use
Download the Script: Grab the script from this repository and save it to your system.
Configuration: Open the script in your favorite editor and tweak the settings:
$CriticalFiles: Add the paths of files you want to monitor.
$AlertEmail: Set the email address where you want to receive alerts.
$LogPath: Specify where the logs and reports should be saved.
$HashBaselineFile: Path to the baseline hash file for file integrity monitoring.
$NetworkInterfaces: List of network interfaces to monitor.
Run the Script: Simply execute the script in PowerShell. You can set it up as a scheduled task to run periodically.
Check Your Inbox: After running the script, check your email for any alerts and the daily security report.

🧰 Requirements
Windows PowerShell: The script runs on PowerShell, so make sure you have it installed.
SMTP Server: To send email alerts, you’ll need access to an SMTP server. Update the Send-MailMessage command in the script with your SMTP details.
Windows Update Module: If you want to check for patch compliance, install the Windows Update PowerShell module (PSWindowsUpdate).
