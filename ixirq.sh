#!/bin/sh
#
# WARNING: Binding IRQs to a core will put system at risk of instability
#          even after unbinding, and will require a reboot
#
basedir=`dirname $0`
binding="ix0:0:16 ix0:1:17 ix0:2:18 ix0:3:19 ix0:4:20 ix0:5:21 ix0:6:22 ix0:7:23 ix1:0:24 ix1:1:25 ix1:2:26 ix1:3:27 ix1:4:28 ix1:5:29 ix1:6:30 ix1:7:31"
release=0

# if "-r" is given as parameter, threads affinity will be unbound

if [ $# -gt 0 ]; then
  if [ $1 = "-r" ]; then
    release=1
  fi
fi


for l in ${binding}; do
    if [ -n "$l" ]; then
        iface=`echo $l | cut -f 1 -d ":"`
        queue=`echo $l | cut -f 2 -d ":"`
        cpu=`echo $l | cut -f 3 -d ":"`
        irq=`vmstat -i | grep "${iface}:que ${queue}" | cut -f 1 -d ":" | sed "s/irq//g"`
		if [ $release -gt 0 ]; then
	        echo "Binding ${iface} queue #${queue} (irq ${irq}) -> CPU${cpu}"
	        cpuset -l $cpu -x $irq
		else
	        echo "Unbinding ${iface} queue #${queue} (irq ${irq}) -> CPU${cpu}"
        	cpuset -l all -x $irq
		fi
    fi
done

