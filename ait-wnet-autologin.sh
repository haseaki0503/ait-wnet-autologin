#!/bin/sh
AUTH_URL="http://1.1.1.1/cgi-bin/Login.cgi"
AITECH_UID=""
AITECH_PWD=""
WIFI_SSID="ait-wnet"
WIFI_PWD=""
SLEEP_TIME=30s

reconect_network () {
  networksetup -setairportpower en0 off
  networksetup -setairportpower en0 on
  networksetup -setairportnetwork en0 $WIFI_SSID $WIFI_PWD
}

while :
do
  CONECTION_STATE=`curl -LI google.com -o /dev/null -w '%{http_code}\n' -s`
  SSID=`/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I | grep ait-wnet`
  NOW=`date "+%H:%M:%S"`
  PROCESS_STATE="ERR!"

  if [ -n "$SSID" ] && [ "$CONECTION_STATE" = "501" ]
  then
    RESULT=`curl -s --interface en0 -m 2\
      -d "uid=$AITECH_UID&pwd=$AITECH_PWD" $AUTH_URL | grep "Login success"`

    if [ "$RESULT" = "Login success" ]
      then
        PROCESS_STATE="Login succeed"
    elif :
      then
        PROCESS_STATE="Login failed"
        reconect_network
    fi

    SLEEP_TIME=1s

  elif [ -n "$SSID" ] && [ "$CONECTION_STATE" = "200" ]
    then
      PROCESS_STATE="Already Logedin"
      SLEEP_TIME=30s
  elif :
    then 
      PROCESS_STATE="Not Connected to ait-wnet"
      SLEEP_TIME=30s
  fi

  echo "["$NOW"] "$PROCESS_STATE
  sleep $SLEEP_TIME
done
