#!/bin/bash

# Bash script to mark plus articles read in nextcloud database in nextcloud newsreader, 
# as most sites do not offer a special RSS feed without their paid content.
# Supported plus websites:
# - Spiegel plus
# - faz.net plus
# - Zeit plus
#
# The script was written for personal use, hence expecting a docker setup.
# It was created to be run via the hosts cron and expects database credentials to be in /root/.my.cnf
# within the database container (mariadb will look there)
#
# Copyright (C) 2019 chris42
#
# This program is free software; you can redistribute it and/or modify it under the terms 
# of the GNU General Public License as published by the Free Software Foundation; 
# either version 3 of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
# without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
# See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with this program; 
# if not, see <http://www.gnu.org/licenses/>.

# config setup
dbContainer="mariadb"
dbName="nextcloud"


# check_url tests given url for plus properties. Returns true only for cases with plus properties, everything else is false.
check_url () {

    case $1 in
    *"faz.net"*)
        if [ -n "$(curl -s $1 | grep 'js-ctn-PaywallTeasers')" ]; then
            return 0
        else
            return 1
        fi
        ;;
    *"spiegel.de"*)
        if [[ "$1" == *"www.spiegel.de/plus"* ]]; then
            return 0
        else
            return 1
        fi
        ;;
    *"zeit.de"*)
        if [ -n "$(curl -s $1 | grep 'class="zplus-badge')" ]; then
            return 0
        else
            return 1
        fi
        ;;
    *)
        # Not supported url, return false
        return 1        
        ;;
    esac
}


###
## Main
###

# Check if database is running
if [ $(docker inspect -f '{{.State.Running}}' "$dbContainer") = "true" ]; then

    # Get last position from file or reset to zero
    if [ -e "/tmp/last_url_checked" ]; then
        lastUrlChecked=$(cat /tmp/last_url_checked)
    else
        lastUrlChecked=0
    fi

    # Get all unread articles from the database
    mapfile -t url_list <<< $(/usr/bin/docker exec "$dbContainer" mysql -N --database="$dbName" --execute="SELECT id,url FROM oc_news_items WHERE unread=1 AND id>$lastUrlChecked;")

    # Check SQL return if empty
    if [ -z "$url_list" ];
    then
        exit 1
    else
        # Check every url, only update database to read when plus article found.
        for i in "${url_list[@]}"
            do
                urlId=$(echo "$i" | cut -f 1)
                url=$(echo "$i" | cut -f 2)
                if check_url "$url"; then
                    /usr/bin/docker exec "$dbContainer" mysql --database="$dbName" --execute="UPDATE oc_news_items SET unread=0 WHERE id=\"$urlId\";"
                fi
                if [ $urlId -gt $lastUrlChecked ]; then
                    lastUrlChecked=$urlId
                fi
        done
        echo "$lastUrlChecked" > /tmp/last_url_checked
    fi
else
    exit 1
fi
