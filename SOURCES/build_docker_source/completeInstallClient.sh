#!/bin/bash
#########################################
#
# Copyright (C) 2016 EyesOfNetwork Team
# DEV NAME : Benoit Village Jan 2016
# 
# VERSION 2.01
# 
# LICENCE :
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
#########################################

BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ -d "$BASEDIR/install_sources" ]; then
	tar cvf $BASEDIR/$(date +'%Y_%m_%d_%s')_install_source.tar $BASEDIR/install_sources/*
	echo "Existing install source saved in .tar in $BASEDIR/"
	rm -rf $BASEDIR/install_sources
	mkdir $BASEDIR/install_sources
else
	mkdir $BASEDIR/install_sources
fi

if [ -f "$BASEDIR/install_source.tar.gz" ]; then
	cp $BASEDIR/install_source.tar.gz $BASEDIR/install_sources
	cd $BASEDIR/install_sources
	tar xvzf $BASEDIR/install_sources/install_source.tar.gz
	$BASEDIR/install_sources/source_ssh_initialisation.sh
	$BASEDIR/install_sources/source_transfert_scheduling_silent.sh
fi

source $BASEDIR/install_sources/setSourceVariable.sh

chmod +x $BASEDIR/install_sources/*

mkdir -p /srv/eyesofreport/depot/lilac 2> /dev/null
mkdir -p /srv/eyesofreport/depot/ged 2> /dev/null
mkdir -p /srv/eyesofreport/depot/nagiosbp 2> /dev/null


lilac_continue=1
while [ -n "$(cat /etc/cron.d/eyesofreport | grep -n -m 1 "/srv/eyesofreport/depot/dump_lilac.sh" | awk -F ":" '{print $1}')" ]; 
do
		myLine=$(cat /etc/cron.d/eyesofreport | grep -n -m 1 "/srv/eyesofreport/depot/dump_lilac.sh" | awk -F ":" '{print $1}')
		sed -i -e "$myLine"'d' /etc/cron.d/eyesofreport
done

if [ $lilac_continue -eq 1 ]; then
	echo "30 0 * * * root /srv/eyesofreport/depot/dump_lilac.sh > /srv/eyesofreport/depot/dump_lilac.log" >> /etc/cron.d/eyesofreport
	echo "MYSQL_PWD=root66 mysqldump -uroot  lilac > /srv/eyesofreport/depot/lilac/${source_name}_lilac.sql" > /srv/eyesofreport/depot/dump_lilac.sh
	chmod +x /srv/eyesofreport/depot/dump_lilac.sh
	echo -e "Lilac dump schduling in /etc/cron.d/eyesofreport	 \e[92m[OK] \e[39m"
fi

ged_continue=1
while [ -n "$(cat /etc/cron.d/eyesofreport | grep -n -m 1 "/srv/eyesofreport/depot/dump_ged.sh" | awk -F ":" '{print $1}')" ]; 
do
		myLine=$(cat /etc/cron.d/eyesofreport | grep -n -m 1 "/srv/eyesofreport/depot/dump_ged.sh" | awk -F ":" '{print $1}')
		sed -i -e "$myLine"'d' /etc/cron.d/eyesofreport
done

if [ $ged_continue -eq 1 ]; then
	echo "32 0 * * * root /srv/eyesofreport/depot/dump_ged.sh > /srv/eyesofreport/depot/dump_ged.log" >> /etc/cron.d/eyesofreport
	echo "MYSQL_PWD=root66 mysqldump -uroot  ged > /srv/eyesofreport/depot/ged/${source_name}_ged.sql" > /srv/eyesofreport/depot/dump_ged.sh
	chmod +x /srv/eyesofreport/depot/dump_ged.sh
	echo -e "Ged dump schduling in /etc/cron.d/eyesofreport	 \e[92m[OK] \e[39m"
fi

nagiosbp_continue=1
while [ -n "$(cat /etc/cron.d/eyesofreport | grep -n -m 1 "/srv/eyesofreport/depot/dump_nagiosbp.sh" | awk -F ":" '{print $1}')" ]; 
do
		myLine=$(cat /etc/cron.d/eyesofreport | grep -n -m 1 "/srv/eyesofreport/depot/dump_nagiosbp.sh" | awk -F ":" '{print $1}')
		sed -i -e "$myLine"'d' /etc/cron.d/eyesofreport
done

if [ $nagiosbp_continue -eq 1 ]; then
	echo "34 0 * * * root /srv/eyesofreport/depot/dump_nagiosbp.sh > /srv/eyesofreport/depot/dump_nagiosbp.log" >> /etc/cron.d/eyesofreport
	echo "MYSQL_PWD=root66 mysqldump -uroot  nagiosbp > /srv/eyesofreport/depot/nagiosbp/${source_name}_nagiosbp.sql" > /srv/eyesofreport/depot/dump_nagiosbp.sh
	chmod +x /srv/eyesofreport/depot/dump_nagiosbp.sh
	echo -e "Nagiosbp dump schduling in /etc/cron.d/eyesofreport	 \e[92m[OK] \e[39m"
fi
