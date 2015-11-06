# docker-nagios

Docker container for [Nagios 4.1.1][3]

"Nagios Is The Industry Standard In IT Infrastructure Monitoring. Achieve instant awareness of IT infrastructure problems, so downtime doesn't adversely affect your business.Nagios offers complete monitoring and alerting for servers, switches, applications, and services."

## Install dependencies

  - [Docker][2]

To install docker in Ubuntu 15.04 use the commands:

    $ sudo apt-get update
    $ wget -qO- https://get.docker.com/ | sh

 To install docker in other operating systems check [docker online documentation][4]

## Usage

To run container use the command below:

    $ docker run -d -p 25 -p 80 quantumobject/docker-nagios

login : nagiosadmin   passdword: admin  please replace it after install.

to access the container please use :

    $ docker exec -it container_id  /bin/bash
    $ export TERM=xterm       #needed to execute some command correctly (nano,top)

to replace password :

    $ htpasswd -c /usr/local/nagios/etc/htpasswd.users nagiosadmin

Update (2015/03/19) Added NRPE checks support.

## More Info

About Nagios [www.nagios.org][1]

To help improve this container [quantumobject/docker-nagios][5]

For additional info about us and our projects check our site [www.quantumobject.com][6]

[1]:http://www.nagios.org/
[2]:https://www.docker.com
[3]:http://www.nagios.org/download
[4]:http://docs.docker.com
[5]:https://github.com/QuantumObject/docker-nagios
[6]:http://www.quantumobject.com/
