#!/bin/sh

#
# Bind interface queues to different cpu cores to reduce
# context switching and cpu cache misses
#

# start from this core 
cpu=0
interfaces="ix0 ix1"
release=0

# if "-r" is given as parameter, threads affinity will be unbound

if [ $# -gt 0 ]; then
  if [ $1 = "-r" ]; then
    release=1
  fi
fi


basedir=`dirname $0`
for int in ${interfaces}; do
  for t in `procstat -ak | grep "${int} que" | awk '{print $2}'`; do
    if [ -n "$t" ]; then
      if [ $release -gt 0 ]; then
        echo "Unbinding ${int} kernel queue (thread #${t})"
        cpuset -l all -t $t
      else
        echo "Binding ${int} kernel queue (thread #${t}) -> CPU${cpu}"
        cpu=`expr $cpu + 1`
        cpuset -l $cpu -t $t
      fi
    fi
  done
done

