############################################################
# Dockerfile to build the Ubuntu 1404 LTS Base Container
# Based on appcontainers/ubuntucore
############################################################

# Set the base image to Ubunutu Core 14.04 LTS Base
FROM appcontainers/ubuntucore

# File Author / Maintainer
MAINTAINER Rich Nason rnason@appcontainers.com

#*************************
#*       Versions        *
#*************************



#**********************************
#* Override Enabled ENV Variables *
#**********************************


#**************************
#*   Add Required Files   *
#**************************


#*************************
#*  Update and Pre-Reqs  *
#*************************
# Fix Init System
RUN dpkg-divert --local --rename --add /sbin/initctl && ln -sf /bin/true /sbin/initctl
RUN dpkg-divert --local --rename /usr/bin/ischroot && ln -sf /bin/true /usr/bin/ischroot

# Fix the udev exit problem when doing an apt-get update
RUN sed -i '/###\ END\ INIT\ INFO/a exit\ 0' /etc/init.d/udev

RUN apt-get clean
RUN apt-get -y update
RUN DEBIAN_FRONTEND=noninteractive apt-get -y upgrade

# Install wget and other utils, wget is required for installing epel and remi repos
RUN apt-get -y install net-tools vim wget openssh-client screen ntp tar git && \

# Remove yum cache this bad boy can get big
apt-get clean && \
rm -fr /var/cache/* 

# Remove the udev fix to put it back to normal
RUN sed -i '/exit0/d' /etc/init.d/udev

#*************************
#*  Application Install  *
#*************************
# Add TermColor Script
ADD termcolor.sh /etc/profile.d/

#************************
#* Post Deploy Clean Up *
#************************
# Set NTP
RUN ntpdate pool.ntp.org

#**************************
#*  Config Startup Items  *
#**************************
RUN echo "service ntp start" >> ~/.bashrc && \
echo "service rsyslog start" >> ~/.bashrc && \
echo "service cron start" >> ~/.bashrc && \
echo "source /etc/profile.d/termcolor.sh" >> ~/.bashrc

CMD /bin/bash

#****************************
#* Expose Applicatoin Ports *
#****************************
# Expose ports to other containers only
