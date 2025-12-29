***This script transforms a basic Debian Linux 13 installation into an HTML kiosk.***

**Requirements:**
- A basic Debian installation without a graphic environment (GUI). Also know as minimal.

*The script will install:* 
- The Fluxbox graphical environment
- Firefox ESR will be installed.
- Starting script and watchdog script (If Firefox closes, it will always start the service automatically).
- A Samba server with the shared folder where the HTML files should go.

In the next update, I will prepare the script to transform it into either a kiosk or a basic Digital Signage player.

*Also:*

- FTP Server.
- More control
- HTML Interfase

*Usage:*

Download the script

Run it:

chmod +x creat.sh

./creat.sh
