# endpoint-checker
A simple bash task and systemd service for checking local endpoint information 
from services like ngrok, and emailing changes.

## Installation

### Prerequisites
Make sure SSMTP is setup and working on your system first.  

Currently the script only checks ngrok; make sure ngrok is configured to run 
automatically. I recommend https://github.com/vincenthsu/systemd-ngrok.

### endpoint-checker
```
$ cd /opt
$ sudo git clone https://github.com/nicoseddio/endpoint-checker.git
$ cd endpoint-checker
$ sudo nano endpoint-checker.sh
```
Change recipients to your email address and update intervals if desired. Save 
and close, and then continue installation.  

```
$ sudo mv endpoint-checker.service /lib/systemd/system/
$ sudo systemctl enable endpoint-checker.service
$ sudo systemctl start endpoint-checker.service
```

Check the log with `cat /opt/endpoint-checker/runtime.log`.  
Check for errors with `cat /opt/endpoint-checker/error.log`.  