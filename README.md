Bash script to mark plus articles read in nextcloud database in nextcloud newsreader, as most sites do not offer a special RSS feed without their paid content.
Supported plus websites:
- Spiegel plus
- faz.net plus
- Zeit plus
- Heise plus
- Sueddeutsche plus

The script was written for personal use, hence expecting a docker setup.
It was created to be run via the hosts cron and expects database credentials to be in /root/.my.cnf
within the database container (mariadb will look there)

Copyright (C) 2020 chris42

This program is free software; you can redistribute it and/or modify it under the terms 
of the GNU General Public License as published by the Free Software Foundation; 
either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program; 
if not, see <http://www.gnu.org/licenses/>.
