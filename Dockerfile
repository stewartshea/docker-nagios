#name of container: docker-nagios
#versison of container: 0.5.5
FROM quantumobject/docker-baseimage:16.04
MAINTAINER Angel Rodriguez  "angel@quantumobject.com"

# Allow postfix to install without interaction.
RUN echo "postfix postfix/mailname string example.com" | debconf-set-selections
RUN echo "postfix postfix/main_mailer_type string 'Internet Site'" | debconf-set-selections

RUN echo "deb http://archive.ubuntu.com/ubuntu/ xenial-updates multiverse" >> /etc/apt/sources.list
RUN echo "deb-src http://archive.ubuntu.com/ubuntu/ xenial-updates multiverse" >> /etc/apt/sources.list
RUN echo "deb http://archive.ubuntu.com/ubuntu/ xenial multiverse" >> /etc/apt/sources.list
RUN echo "deb-src http://archive.ubuntu.com/ubuntu/ xenial multiverse" >> /etc/apt/sources.list

#add repository and update the container
#Installation of nesesary package/software for this containers...
RUN apt-get update && apt-get install -y -q  wget \
                    git \
                    build-essential \
                    apache2 \
                    apache2-utils \
                    iputils-ping \
                    php7.0-gd \
                    libapache2-mod-php7.0 \
                    postfix \
                    libssl-dev \
                    unzip \
                    libdigest-hmac-perl \
                    libnet-snmp-perl \
                    libcrypt-des-perl \
                    mailutils \
                    snmp \
                    lm-sensors snmp-mibs-downloader \
                    dnsutils \
                    nagios-nrpe-plugin \
                    automake \
                    libtool \
                    autoconf \
                    && rm -R /var/www/html \
                    && apt-get clean \
                    && rm -rf /tmp/* /var/tmp/*  \
                    && rm -rf /var/lib/apt/lists/*

## Install Gluster Plugin
#RUN wget https://github.com/gluster/nagios-plugins-gluster/archive/master.zip \
#    && unzip master.zip \
#    && cd nagios-plugins-gluster-master \
#    && ls -lha

RUN git clone https://github.com/gluster/nagios-plugins-gluster.git \
    && cd nagios-plugins-gluster \
    && git fetch --all \
    && git describe --always \
    && autoreconf -i\
    && ls -lha \
    && ./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --libdir=/usr/lib \
    && make \
    && make install

##startup scripts
#Pre-config scrip that maybe need to be run one time only when the container run the first time .. using a flag to don't
#run it again ... use for conf for service ... when run the first time ...
RUN mkdir -p /etc/my_init.d
COPY startup.sh /etc/my_init.d/startup.sh
RUN chmod +x /etc/my_init.d/startup.sh

##Get Mibs
RUN /usr/bin/download-mibs
RUN echo 'mibs +ALL' >> /etc/snmp/snmp.conf

# RUN ln -s /usr/lib/x86_64-linux-gnu/libssl.so /usr/lib/x86_64-linux-gnu/libssl.so.10

#RUN ln -s /lib/x86_64-linux-gnu/libssl.so.1.0.0 /usr/lib/x86_64-linux-gnu/libssl.so.10

#Create libcrypto simlink
#RUN ln -s /usr/lib/x86_64-linux-gnu/libcrypto.so /usr/lib/x86_64-linux-gnu/libcrypto.so.10




##Adding Deamons to containers
# to add apache2 deamon to runit
RUN mkdir -p /etc/service/apache2  /var/log/apache2 ; sync
RUN mkdir /etc/service/apache2/log
COPY apache2.sh /etc/service/apache2/run
COPY apache2-log.sh /etc/service/apache2/log/run
RUN chmod +x /etc/service/apache2/run /etc/service/apache2/log/run \
    && cp /var/log/cron/config /var/log/apache2/ \
    && chown -R www-data /var/log/apache2

# to add nagios deamon to runit
RUN mkdir /etc/service/nagios /var/log/nagios ; sync
RUN mkdir /etc/service/nagios/log
COPY nagios.sh /etc/service/nagios/run
COPY nagios-log.sh /etc/service/nagios/log/run
RUN chmod +x /etc/service/nagios/run /etc/service/nagios/log/run \
    && cp /var/log/cron/config /var/log/nagios/ \
    && chown -R root /var/log/nagios

# to add postfix deamon to runit
RUN mkdir /etc/service/postfix /var/log/postfix ; sync
RUN mkdir /etc/service/postfix/log
COPY postfix.sh /etc/service/postfix/run
COPY postfixstop.sh /etc/service/postfix/finish
COPY postfix-log.sh /etc/service/postfix/log/run
RUN chmod +x /etc/service/postfix/run /etc/service/postfix/finish /etc/service/postfix/log/run \
    && cp /var/log/cron/config /var/log/postfix/ \
    && chown -R root /var/log/postfix

#pre-config scritp for different service that need to be run when container image is create
#maybe include additional software that need to be installed ... with some service running ... like example mysqld
COPY pre-conf.sh /sbin/pre-conf
RUN chmod +x /sbin/pre-conf ; sync
RUN /bin/bash -c /sbin/pre-conf \
    && rm /sbin/pre-conf


##Copy plguins installed though apt to location
RUN cp /usr/lib/nagios/plugins/check_nrpe /usr/local/nagios/libexec/ ; sync

##scritp that can be running from the outside using docker-bash tool ...
## for example to create backup for database with convitation of VOLUME   dockers-bash container_ID backup_mysql
COPY backup.sh /sbin/backup
RUN chmod +x /sbin/backup
VOLUME /var/backups

# to allow access from outside of the container  to the container service
# at that ports need to allow access from firewall if need to access it outside of the server.
EXPOSE 80 25

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]
