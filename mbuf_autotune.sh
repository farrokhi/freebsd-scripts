#!/bin/sh

#
# Copyright (c) 2016 Babak Farrokhi.  All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.
#

#
# Suggest optimum value for kern.ipc.*
# based on /sys/kern/kern_mbuf.c
#

MCLBYTES=2048
MSIZE=256
PHYSMEM=`sysctl -n hw.physmem`
PAGE_SIZE=`sysctl -n hw.pagesize`
VM_KMEM_SIZE=`sysctl -n vm.kmem_size`
REALMEM=${VM_KMEM_SIZE}
MAXMBUFMEM=`expr $REALMEM / 4 \* 3`
MJUMPAGESIZE=$PAGE_SIZE
MJUM9BYTES=`expr 9 \* 1024`
MJUM16BYTES=`expr 16 \* 1024`

NMBCLUSTERS=`expr $MAXMBUFMEM / $MCLBYTES / 4`
NMBJUMBOP=`expr $MAXMBUFMEM / $MJUMPAGESIZE / 4`
NMBJUMBO9=`expr $MAXMBUFMEM / $MJUM9BYTES / 6`
NMBJUMBO16=`expr $MAXMBUFMEM / $MJUM16BYTES / 6`

NMBUFS=`sysctl -n kern.ipc.nmbufs`
NMMAX1=`expr $NMBCLUSTERS + $NMBJUMBOP + $NMBJUMBO9 + $NMBJUMBO16`
NMMAX2=`expr $MAXMBUFMEM / $MSIZE / 5`
if [ $NMMAX1 -gt $NMMAX2 ]; then
	NMBUFS=$NMMAX1
else
	NMBUFX=$NMMAX2
fi

show()
{
	echo "# `basename $0 ` suggested settings:"
	echo "kern.ipc.maxmbufmem=$MAXMBUFMEM"
	echo "kern.ipc.nmbclusters=$NMBCLUSTERS"
	echo "kern.ipc.nmbjumbop=$NMBJUMBOP"
	echo "kern.ipc.nmbjumbo9=$NMBJUMBO9"
	echo "kern.ipc.nmbjumbo16=$NMBJUMBO16"
	echo "kern.ipc.nmbufs=$NMBUFS"
}

compare()
{
	echo "kern.ipc.maxmbufmem:  `sysctl -n kern.ipc.maxmbufmem` (current)"
	echo "                 -->  $MAXMBUFMEM (suggested)"
	echo "kern.ipc.nmbclusters: `sysctl -n kern.ipc.nmbclusters`"
	echo "                  --> $NMBCLUSTERS"
	echo "kern.ipc.nmbjumbop:   `sysctl -n kern.ipc.nmbjumbop`"
	echo "                -->   $NMBJUMBOP"
	echo "kern.ipc.nmbjumbo9:   `sysctl -n kern.ipc.nmbjumbo9`"
	echo "                -->   $NMBJUMBO9"
	echo "kern.ipc.nmbjumbo16:  `sysctl -n kern.ipc.nmbjumbo16`"
	echo "                 -->  $NMBJUMBO16"
	echo "kern.ipc.nmbufs:      `sysctl -n kern.ipc.nmbufs`"
	echo "             -->      $NMBUFS"
}

if [ $# -gt 0 ]; then
	if [ $1 == '-c' ]; then
		compare
		exit 0
	fi
fi

show
