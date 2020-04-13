#!/bin/bash
#
# Copyright (c) 2019, 2020, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at http://oss.oracle.com/licenses/upl.
#

mkdir -p /var/run/essbase-init
chown oracle:oracle /var/run/essbase-init

logfile=/var/log/essbase-init.log

touch $logfile
exec > >(tee -i $logfile) 2>&1

# Add trap to create exit status file
onComplete() {
  rv=$?
  umask 022
  echo $rv > /var/run/essbase-init/.essbase-init.completed
  rm -rf /var/run/essbase-init/essbase-init.pid
}

trap onComplete EXIT

scriptpid=$$
echo $scriptpid > /var/run/essbase-init/essbase-init.pid

# Display version information
/u01/vmtools/version.sh

# Run the configure_volumes script, with a timeout of 20m
timeout -s SIGKILL 20m /u01/vmtools/configure_volumes.sh

# Update the essbase service configuration file for the mounts, but do not start
sed -i '/^After=.*/a RequiresMountsFor=/u01/config /u01/data' /etc/systemd/system/essbase.service
systemctl daemon-reload

echo Running configuration script
timeout -s SIGKILL 60m /u01/vmtools/configure.sh

