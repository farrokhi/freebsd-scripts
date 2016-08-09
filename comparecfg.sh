#!/bin/sh

showall=0

if [ $# -gt 0 ]; then
  if [ $1 == "-a" ]; then
    showall=1
  fi
fi

chkcfg() {

  cfg=${1}; shift;
  if [ ! -f ${cfg} ]; then
    "cannot open ${cfg}"
    return
  fi

  echo
  echo "===> Comparing ${cfg}"
  echo

  for i in `cat ${cfg} | grep '=' | grep '\.' | sed 's/^#//' | cut -f1 -d=`; do
    desc=`sysctl -nd ${i} 2>/dev/null`
    cmdresult=0
    curval=`sysctl -n ${i} 2>/dev/null`
    cmdresult=$?
    cfgval=`grep ${i}= ${cfg} | tail -n1 |  cut -f2 -d= | sed 's/\"//g'`

    if [ X${curval} != X${cfgval} ] || [ ${showall} -eq 1 ]; then

      if [ ${cmdresult} -ne 0 ]; then
        curval="** sysctl returned error**"
      fi


      echo "      Name: ${i}"
      echo "      Desc: ${desc}"
      echo "   Current: ${curval}"
      echo "    Config: ${cfgval}"
      echo
    fi
  done
}

chkcfg "/etc/sysctl.conf"
chkcfg "/boot/loader.conf"

