#!/bin/bash
# Written by Nico Seddio
# Initial:	 2/26/22
# Last updated:	 2/26/22
# Description:
#   Checks ngrok instance information for changes in endpoint.
#   Emails changes as they are discovered.
#   Requires SSMTP to be installed and configured.

# Configuration
RECIPIENTS="YOUR_EMAIL_HERE"
SLEEP_TIMER=10 # Minutes
# How often to trigger a renewal email.
# Google disables less secure app access if not regularly used.
# Set to less than 1 to disable.
RENEWAL_INTERVAL=7 # Days

# Print status
echo "Endpoint checker started."
echo "Recipients are: $RECIPIENTS"
echo "Sleep timer set to: $SLEEP_TIMER minutes"
if [ $RENEWAL_INTERVAL -gt 0 ]; then
  echo "Renewal emails enabled, set to every $RENEWAL_INTERVAL days."
fi

# Initialization
ENDPOINT_CACHE=""
RUN_TIMER=0
RENEWAL_INTERVAL=$(($RENEWAL_INTERVAL * 60 * 60 * 24)) # Convert to seconds
SLEEP_TIMER=$(($SLEEP_TIMER * 60)) # Convert to seconds
timestamp() { 
  date +"%Y%m%d_%H%M%S" # yyyymmdd_HHMMSS
}

# ngrok takes time to boot
echo "$(timestamp): Awaiting endpoint to boot."
sleep 60

while true; do
  # Get ngrok status
  echo "$(timestamp): Checking endpoint..."
  ENDPOINT=$(curl --silent --show-error http://127.0.0.1:4040/api/tunnels)

  # If changed, update cache and send email
  if [ "$ENDPOINT" != "$ENDPOINT_CACHE" ]; then
    echo -e "To: $RECIPIENTS \nSubject: ngrok Status Update \n\n$ENDPOINT" | ssmtp -t
    ENDPOINT_CACHE=$ENDPOINT
    echo "$(timestamp): Endpoint changed. Email sent."
  fi

  # If renewals are enabled, update runtime and send renewal if time
  if [ $RENEWAL_INTERVAL -gt 0 ]; then
    RUN_TIMER=$(($RUN_TIMER + $SLEEP_TIMER))
    if [ $RUN_TIMER -ge $RENEWAL_INTERVAL ]; then
      echo -e "To: $RECIPIENTS \nSubject: Renewal Email \n\nThis is an email to renew mail provider authentication with less secure app access." | ssmtp -t
      RUN_TIMER=0
      echo "$(timestamp): Renewal email sent."
    fi
  fi

  sleep $SLEEP_TIMER
done
