#!/bin/bash
checkInput () {
      if [ -z "$1" ]
      then
            echo "input missing:$2"
            exit 1
      else
            echo "[validate_input] $2=$1"
      fi
  
}
checkInput "${ZAP_TARGET_URL}" "ZAP_TARGET_URL"
checkInput "${ZAP_ALERT_LVL}" "ZAP_ALERT_LVL"
