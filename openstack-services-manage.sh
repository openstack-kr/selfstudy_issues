#!/bin/bash
#
# Description: Manage OpenStack main component services
#              (Requires root previlege to start/stop services)
#
# Contributors: Ian Y. Choi / OpenStack Korea Community
#
# Usage example:
#  $ ./openstack-services-manage.sh status
#
# Note:
#  - Currently tested on Ubuntu 14.04 LTS
#
# License: Apache Software License (ASL) 2.0
#

# Assumes that the default init directory is /etc/init/ (Ubuntu 14.04 LTS)
SERVICE_DIR='/etc/init/'
SED_SERVICE_DIR=`echo $SERVICE_DIR | sed 's/\//\\\\\//g'`

# Prints basic usage if there is no command argument
USAGE="Usage: `basename $0` [command (start|stop|status|reload)]"
if [ $# -eq 0 ]; then
  echo "${USAGE}" >&2
  exit 1
fi

# Prints basic usage if users input non-supported commands
LIST="start stop status reload"
if ! [[ $LIST =~ (^| )$1($| ) ]]; then
  echo "${USAGE}" >&2
  exit 1
fi

# Prints ERROR if the executing user is not 'root'.
USER_NAME=`whoami`
if [ $USER_NAME != "root" ]; then
  echo "ERROR! This script requires root previlege."
  exit 1
fi

# Function
function operation ()
{
  CONFS=`ls $SERVICE_DIR/$1* 2>/dev/null`
  SVCS=`echo $CONFS | sed "s/${SED_SERVICE_DIR}\///g" | sed 's/.conf//g'`
  CNT=`echo $SVCS | wc -w`
  if [ $CNT > 0 ]; then
    for svc in $SVCS; do
      service $svc $2
    done
  fi
}

# k. Identity Service: keystone
TARGET='keystone'
echo "  [[ ${TARGET} ]]"
operation $TARGET $1

# g. Image Service: glance
TARGET='glance'
echo "  [[ ${TARGET} ]]"
operation $TARGET $1

# c. Compute Service: nova
TARGET='nova'
echo "  [[ ${TARGET} ]]"
operation $TARGET $1

# q. Network Service: Neutron
TARGET='neutron'
echo "  [[ ${TARGET} ]]"
operation $TARGET $1

# b. Block Storage Service: cinder
TARGET='cinder'
echo "  [[ ${TARGET} ]]"
operation $TARGET $1

