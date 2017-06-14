#!/bin/bash
#set -exv
set -e
echo "entrypoint.sh commmandline: $@"

if [ "${1:0:1}" = '-' ]; then
	echo "Matched - in first if"
	set -- catalina.sh run
fi

if [ "$1" = 'catalina.sh' ]; then
	
	echo "Modifing viewers.xml.conf based on environment variable before startup (user is: "`whoami`")"
	if [ "$OLFS_WMS_VIEWERS_HOSTPORT" ]; then
		sed -i "s/OLFS_WMS_VIEWERS_HOSTPORT/$OLFS_WMS_VIEWERS_HOSTPORT/" ${CATALINA_HOME}/webapps/opendap/WEB-INF/conf/viewers.xml
	fi
        echo "CATALINA_HOME: "$CATALINA_HOME
	ls -l "$CATALINA_HOME" "$CATALINA_HOME/bin"
        shift
        #exec gosu tomcat "$CATALINA_HOME/bin/start_tomcat.sh $@"
        exec gosu root "$CATALINA_HOME/bin/start-tomcat.sh"
fi

exec "$@"
