PI1=192.168.7.28
PI2=192.168.7.179
HAPROXY_FILE=/root/haproxy-conf/haproxy-guts
PORT_NUMBER=8080
echo -n "HOW MANY ON EACH NODE MASTER?: "
read ANSWER
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
 docker -H tcp://127.0.0.1:3456 run -d -p ${PORT_NUMBER}:80 hypriot/rpi-busybox-httpd
 docker -H tcp://127.0.0.1:3456 run -d -p ${PORT_NUMBER}:80 hypriot/rpi-busybox-httpd
 # EXAMPLE HAX
 echo "server pi1-port${PORT_NUMBER} ${PI1}:${PORT_NUMBER} check" >> $HAPROXY_FILE
 echo "server pi2-port${PORT_NUMBER} ${PI2}:${PORT_NUMBER} check" >> $HAPROXY_FILE
 let "PORT_NUMBER+=1"
done
# BUILD THE HAPROXY
cat /root/haproxy-conf/haproxy-head > /root/haproxy-conf/haproxy.cfg
cat $HAPROXY_FILE >> /root/haproxy-conf/haproxy.cfg
cat /root/haproxy-conf/haproxy-tail >> /root/haproxy-conf/haproxy.cfg
# LAUNCH HAPROXY
echo "MASTER I SHALL NOW LAUNCH HAPROXY AS REQUESTED"
# this exposes port 80 and 70 also mounts /root/haproxy-conf as /haproxy-override inside the container
docker run -d -p 80:80 -p 70:70 -v /root/haproxy-conf:/haproxy-override hypriot/rpi-haproxy
