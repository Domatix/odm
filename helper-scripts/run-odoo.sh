#!/usr/bin/env bash
#### Written by: Catalin Airimitoaie - catalin@domatix.com
#### Description: Odoo execution script. Do not call this script directly, it will be ran by `../run.sh`.

custom="$HOME/custom"
odoo="$HOME/sources/odoo"
args="$*"
$odoo/env/bin/python $odoo/odoo-bin -c $custom/etc/odoo.tmp.conf  --limit-time-real 99999 --pidfile=$custom/etc/run.pid $args
