#!/bin/sh
AUTH_URL="http://1.1.1.1/cgi-bin/Login.cgi"
AITECH_UID=""
AITECH_PWD=""
WIFI_SSID=""
WIFI_PWD=""
SLEEP_TIME=30s
TRY=0

reconnect_network () {
  echo -n "Reconnecting network..."
  networksetup -setairportpower en0 off
  networksetup -setairportpower en0 on
  networksetup -setairportnetwork en0 $WIFI_SSID $WIFI_PWD
  echo "done."
}
destroy () {
  unset AITECH_PWD
  unset WIFI_PWD
}

echo "Press Ctrl+C to exit."
trap 'destroy; exit 0' 2

while :
do
  SSID=`/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I | grep $WIFI_SSID`
  PROCESS_STATE="ERR!"

  # If not login
  if [ -n "$SSID" ]; then
    CONNECTION_STATE=`curl -I https://www.google.co.jp -o /dev/null -w \
      '%{http_code}\n' -s --interface en0 --connect-timeout 2`

    # If not login.
    if [ "$CONNECTION_STATE" != "200" ]; then
      RESULT=`curl -s -L --interface en0 --connect-timeout 2\
        -d "uid=$AITECH_UID&pwd=$AITECH_PWD" $AUTH_URL | grep "Login success"`

      if [ -n "$RESULT" ]; then
        PROCESS_STATE="Login succeed"
        TRY=0
      else
        TRY=`expr $TRY + 1`
        if [ $TRY -gt 3 ]; then
          echo "Password is wrong. Check config."
          destroy
          exit 1
        fi
        PROCESS_STATE="Login failed."
        reconnect_network
      fi
      SLEEP_TIME=2s

    # If already logged in.
    else
      PROCESS_STATE="Already Logged in"
      SLEEP_TIME=20s
    fi

  else
    PROCESS_STATE="Not Connected to ait-wnet"
    SLEEP_TIME=30s
  fi

  NOW=`date "+%H:%M:%S"`
  echo "["$NOW"] "$PROCESS_STATE
  sleep $SLEEP_TIME
done
