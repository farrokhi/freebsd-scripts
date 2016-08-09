#!/bin/sh

MUNIN_LIBDIR="/usr/local/share/munin"
PLUGIN_PATH=${MUNIN_LIBDIR}/plugins
INSTALL_PATH=/usr/local/etc/munin/plugins
export MUNIN_LIBDIR

# cleanup installed plugins
find ${INSTALL_PATH} -type l -delete

# install plugins
for p in `find ${PLUGIN_PATH} -type f -perm +u+x`; do
	pname=`basename $p`
	if echo ${pname} | grep -q _$; then # plugin name ends with underline
		params=`${p} suggest` || ( echo "failed to collect suggestion from ${pname} plugin"; exit 1)
		for x in ${params}; do
			ln -vs ${p} ${INSTALL_PATH}/${pname}${x}
		done
	else # not a wildcard plugin
		ln -vs ${p} ${INSTALL_PATH}/${pname}
	fi
done
