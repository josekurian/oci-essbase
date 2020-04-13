#!/bin/bash
#
# Copyright (c) 2020, Oracle and/or its affiliates. All rights reserved.
#

while true; do
  if [ -e "/var/run/essbase-init/.essbase-init.completed" ]; then
     break
  fi

  if [ -e "/var/run/essbase-init/essbase-init.pid" ]; then
     break
  fi

  if [ -e "/var/log/essbase-init.log" ]; then
     break
  fi

  echo Waiting for essbase-init script to start...
  sleep 5
done

configurepid=$(cat /var/run/essbase-init/essbase-init.pid 2> /dev/null || echo -1)
if [ "$configurepid" -ne "-1" ]; then
  tail -F -n +1 --pid=$configurepid /var/log/essbase-init.log
else
  cat /var/log/essbase-init.log
fi

while [[ ! -e /var/run/essbase-init/.essbase-init.completed ]]; do
  sleep 5
done

rv=$(cat /var/run/essbase-init/.essbase-init.completed)
if [ "$rv" -ne "0" ]; then
   exit $rv
fi
