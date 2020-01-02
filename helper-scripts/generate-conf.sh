#!/usr/bin/env bash
#### Written by: Catalin Airimitoaie - catalin@domatix.com
#### Description: Odoo config file auto-(re)generation. Do not call this script directly, it will be ran by `../run.sh`.

cd ~/custom
addons=$(cd addons; ls -l | awk '{print $9}') 
if [ -f etc/odoo.tmp.conf ];
then
	rm etc/odoo.tmp.conf
fi

cp etc/odoo.conf etc/odoo.tmp.conf
for addon in $addons
do
	if [[ ! -z "$addon" ]];
	then
		echo -e "	/opt/odoo/custom/addons/$addon," >> etc/odoo.tmp.conf
	fi
done

