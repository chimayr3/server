#!/bin/bash

# function to print usage of this script
function usage() {
	echo "Usage : `basename ${0}` <httpd instance name>" ; exit 1
}

# source for die() and run()  : http://stackoverflow.com/questions/6109225/bash-echoing-the-last-command-run
# function print error message and exit  program
function die() {
	echo "ERROR: ${*}" ; exit 1
}

# execute command and show status or die (function)
run() { 
	${*} >/dev/null 2>&1; RC=${?} 
	if [ "${RC}" = "0" ] ; then
		echo "Exec [${*}] Successfully"
	else
		die "command [${*}] failed with error code ${RC}"
	fi
}

# if user != root => print error msg and exit
if [ "${USER}" != "root" ] ; then
	_exit "this script run only with root user !"
fi

# print usage if not one uniq argument given to this script
if [ "${#}" != 1 ] ; then
	usage
fi

# init vars
HTTPD_INSTANCE="${1}"

# check if <httpd instance name> already exist
if [ -f "/etc/init.d/${HTTPD_INSTANCE}" ] ; then
	_exit "${HTTPD_INSTANCE} already exist"
fi

# make new httpd instance
run cp -a /etc/httpd/ /opt/httpd_${HTTPD_INSTANCE}/

run cp -a /etc/init.d/httpd /etc/init.d/httpd_${HTTPD_INSTANCE}

HTTPD_SYSCONFIG="/etc/sysconfig/httpd_${HTTPD_INSTANCE}"
cat <<EOF > "${HTTPD_SYSCONFIG}"
HTTPD=/usr/sbin/httpd_${HTTPD_INSTANCE}
OPTIONS="-f /opt/httpd_${HTTPD_INSTANCE}/conf/httpd.conf"
LOCKFILE=/var/lock/subsys/httpd_${HTTPD_INSTANCE}
PIDFILE=/var/run/httpd/httpd_${HTTPD_INSTANCE}.pid
EOF

run ln -s /usr/sbin/httpd /usr/sbin/httpd_${HTTPD_INSTANCE}
run cp -l /usr/sbin/apachectl /usr/sbin/apachectl_${HTTPD_INSTANCE}
run sed -i s#/etc/sysconfig/httpd#/etc/sysconfig/httpd_${HTTPD_INSTANCE}#g ${HTTPD_SYSCONFIG}
run sed -i s#/usr/sbin/apachectl#/usr/sbin/apachectl_${HTTPD_INSTANCE}#g ${HTTPD_SYSCONFIG}

# httpd.conf
sed -i "s/ServerRoot \"\/etc\/httpd\"/ServerRoot\ \"\/opt\/httpd_${HTTPD_INSTANCE}\"/" /opt/httpd_${HTTPD_INSTANCE}/conf/httpd.conf
sed -i "s/ServerTokens OS/ServerTokens Prod/" /opt/httpd_${HTTPD_INSTANCE}/conf/httpd.conf
sed -i "s/PidFile run\/httpd.pid/PidFile\ run\/httpd_${HTTPD_INSTANCE}.pid/" /opt/httpd_${HTTPD_INSTANCE}/conf/httpd.conf

# logs
run mkdir /var/log/httpd/${HTTPD_INSTANCE}

rm -f /opt/httpd_${HTTPD_INSTANCE}/logs &&  ln -s /var/log/httpd/${HTTPD_INSTANCE} /opt/httpd_${HTTPD_INSTANCE}/logs
rm -f /opt/httpd_${HTTPD_INSTANCE}/modules && ln -s /usr/lib64/httpd/modules /opt/httpd_${HTTPD_INSTANCE}/modules
rm -f /opt/httpd_${HTTPD_INSTANCE}/run && ln -s /var/run/httpd /opt/httpd_${HTTPD_INSTANCE}/run

# init
sed -i "s/\/etc\/sysconfig\/httpd/\/etc\/sysconfig\/httpd_${HTTPD_INSTANCE}/" /etc/init.d/httpd_${HTTPD_INSTANCE}
sed -i "s/\/usr\/sbin\/apachectl/\/usr\/sbin\/apachectl_${HTTPD_INSTANCE}/" /etc/init.d/httpd_${HTTPD_INSTANCE}

echo "Install successfully new httpd ${HTTPD_NAME} instance !"
exit 0

