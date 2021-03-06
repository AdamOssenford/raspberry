#!/bin/bash
##########################################################
# RASPBERRY PI HTTP SPINNER AND HAPROXY LAUNCHER
##########################################################
# VARIABLES #
#############
PI_LIST="192.168.7.28 192.168.7.61 192.168.7.179"
HAPROXY_DIR=/root/haproxy-conf
HAPROXY_FILE=/tmp/themguts.$$
PORT_NUMBER=8080
DOCKER_IMAGE=adamoss/seckc-web:1.0
##################################
# ASK ABOUT HTTP SERVER COUNTSa
if [ -n $1 ]
then 
   ANSWER=$1
else
 echo -n "HOW MANY ON EACH NODE MASTER?: "
 read ANSWER
fi
if [ "$ANSWER" -gt 1 ]
then 
 COUNT=$ANSWER
else
 COUNT=1
fi
echo "SPINNING UP $COUNT SERVERS"
for i in $(seq 1 $COUNT)
do
# DO ONE FOR EACH NODE PI
for pi in $PI_LIST
do
 docker -H tcp://127.0.0.1:3456 run -d -p ${PORT_NUMBER}:80 $DOCKER_IMAGE
 # EXAMPLE HAX
 echo "server ${pi}-${PORT_NUMBER} ${pi}:${PORT_NUMBER} check" >> $HAPROXY_FILE
done
 let "PORT_NUMBER+=1"
done
# BUILD THE HAPROXY
cat $HAPROXY_DIR/haproxy-head > $HAPROXY_DIR/haproxy.cfg
cat $HAPROXY_FILE >> $HAPROXY_DIR/haproxy.cfg
cat $HAPROXY_DIR/haproxy-tail >> $HAPROXY_DIR/haproxy.cfg
rm $HAPROXY_FILE
# LAUNCH HAPROXY
echo "MASTER I SHALL NOW LAUNCH HAPROXY AS REQUESTED"
# this exposes port 80 and 70 also mounts /root/haproxy-conf as /haproxy-override inside the container
docker run -d -p 80:80 -p 70:70 -v /root/haproxy-conf:/haproxy-override hypriot/rpi-haproxy
