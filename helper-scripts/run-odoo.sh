#!/usr/bin/env bash
#### Written by: Catalin Airimitoaie - catalin@domatix.com
#### Description: Odoo execution script. Do not call this script directly, it will be ran by `../run.sh`.

cd $HOME/custom
echo $$ > etc/run.pid
args="$@"
command="~/sources/odoo/odoo-bin -c etc/odoo.tmp.conf  --limit-time-real 99999 $args"
exec ${command}

