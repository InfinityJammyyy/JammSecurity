REV 1.0 of Jamm Security is now posted.

I am not a proffecinal (mispelled like a true professional) when it comes to bash, also if you get hacked its not my fault. 

```
      ██                                  
     ░██                                  
     ░██  ██████   ██████████  ██████████ 
     ░██ ░░░░░░██ ░░██░░██░░██░░██░░██░░██
     ░██  ███████  ░██ ░██ ░██ ░██ ░██ ░██
 ██  ░██ ██░░░░██  ░██ ░██ ░██ ░██ ░██ ░██
░░█████ ░░████████ ███ ░██ ░██ ███ ░██ ░██
 ░░░░░   ░░░░░░░░ ░░░  ░░  ░░ ░░░  ░░  ░░ 
  ████████                                ██   ██           
 ██░░░░░░                                ░░   ░██    ██   ██
░██         █████   █████  ██   ██ ██████ ██ ██████ ░░██ ██ 
░█████████ ██░░░██ ██░░░██░██  ░██░░██░░█░██░░░██░   ░░███  
░░░░░░░░██░███████░██  ░░ ░██  ░██ ░██ ░ ░██  ░██     ░██   
       ░██░██░░░░ ░██   ██░██  ░██ ░██   ░██  ░██     ██    
 ████████ ░░██████░░█████ ░░██████░███   ░██  ░░██   ██     
░░░░░░░░   ░░░░░░  ░░░░░   ░░░░░░ ░░░    ░░    ░░   ░░      
```

Roadmap:

1. User Management [✓]

Add/Remove Users: Implement a Text User Interface (TUI) to manage users.

View and Revoke Sudo Access: Provide options to see which users have sudo access and revoke it if necessary.

Group Membership: Display groups that each user belongs to.

List Human and Non-Human Users: Categorize users based on system vs. human accounts.

2. Vulnerability Scanning

Tools to Use:

Lynis

Chkrootkit

rkhunter

Output Readability:

Filter outputs to show only errors and warnings.

3. Add Auditing

File Tracking:

Identify recently generated or modified files by human users.

Command Monitoring:

Record commands executed by users.

Use Auditd:

Configure and analyze logs for suspicious activity.

4. Intrusion Detection

Set Up IDS:

Implement tools like AIDE, Snort, or Suricata for intrusion detection.

5. SSH Hardening

Recommendations:

Disable root login.

Enforce key-based authentication.

Change default SSH port.

Use Fail2Ban to block brute force attacks.

Limit SSH access to specific IPs if possible.

6. File Permissions

Review and Set Appropriate Permissions:

Ensure proper read/write/execute permissions for critical files and directories.

7. Program Monitoring

Installed Programs:

List all installed programs.

Highlight programs installed within the past 4 days.

Identify Hacking Programs:

Flag tools commonly used for malicious purposes.

8. File Analysis

Identify Suspicious Files:

Locate unusual files, including audio and video files, that don’t belong on the server.

9. UFW and Network Security

Improve UFW:

Review and update firewall rules.

Packet Handling:

Drop packets that are unnecessary or potentially exploitable (e.g., IPv6 if not in use).

Block malformed or suspicious packets.

10. Additional Hardening

SELinux or AppArmor:

Enable and configure mandatory access control systems.

Kernel Parameters:

Harden sysctl settings for network and system security.

Remove Unnecessary Services:

Disable and uninstall unused or unnecessary services.

11. Dialog-Based Interface [✓]

Program Integration:

Implement a dialog-based TUI to manage and execute the above functionalities.

Separate Output Files:

Ensure logs and outputs are saved to clearly separated files for readability.

