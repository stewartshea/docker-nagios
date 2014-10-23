docker-nagios
=============

container running nagios

docker run -d -p 25 -p 80 quantumobject/docker-nagios

login : nagiosadmin   passdword: admin   please replace it after install ....

to access the container please use 

docker exec -it container_id  /bin/bash


to replace password :

htpasswd -c /usr/local/nagios/etc/htpasswd.users nagiosadmin

