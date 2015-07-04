############################################################
# Dockerfile to build the Ubuntu 14.04 LTS Base Container
# Based on ubuntu
############################################################

# Set the base image to Ubunutu Core 14.04 LTS Base
FROM ubuntu

# File Author / Maintainer
MAINTAINER Rich Nason rnason@appcontainers.com

#*************************
#*       Versions        *
#*************************



#**********************************
#* Override Enabled ENV Variables *
#**********************************
ENV TERMTAG UBUNTU


#**************************
#*   Add Required Files   *
#**************************
ADD termcolor.sh /etc/profile.d/PS1.sh
RUN chmod +x /etc/profile.d/PS1.sh && \
echo "source /etc/profile.d/PS1.sh" >> /root/.bashrc && \
echo "alias vim='nano'" >> /root/.bashrc


#*************************
#*  Update and Pre-Reqs  *
#*************************

# Enable Progress Bar
RUN echo 'Dpkg::Progress-Fancy "1";' | tee -a /etc/apt/apt.conf.d/99progressbar

# This is not required using library/ubuntu as the build root box
###########################################################################################
# Fix Init System
# RUN dpkg-divert --local --rename --add /sbin/initctl && ln -sf /bin/true /sbin/initctl
# RUN dpkg-divert --local --rename /usr/bin/ischroot && ln -sf /bin/true /usr/bin/ischroot
# Fix the udev exit problem when doing an apt-get update
# RUN sed -i '/###\ END\ INIT\ INFO/a exit\ 0' /etc/init.d/udev
###########################################################################################


# Update, upgrade, install nano, and clear
RUN apt-get clean && \
apt-get update && \
DEBIAN_FRONTEND=noninteractive apt-get -y purge \
ubuntu-minimal \
eject \
isc-dhcp-common \
isc-dhcp-client \
kbd \
console-setup \
xkb-data \
vim-common \
vim-tiny \
bzip2 \
apt-utils \
python3.4 \
python3-minimal \
python3.4-minimal \
libpython3-stdlib:amd64 \
libpython3.4-minimal:amd64 \
libpython3.4-stdlib:amd64 \
keyboard-configuration && \
DEBIAN_FRONTEND=noninteractive apt-get -y autoremove && \
DEBIAN_FRONTEND=noninteractive apt-get -y upgrade && \
DEBIAN_FRONTEND=noninteractive apt-get -y install nano && \
rm -fr /var/lib/apt/lists/*

# Clean up after the python install
RUN rm -fr /usr/share/dh-python/


# This is not required using library/ubuntu as the build root box
#########################################
# RUN sed -i '/exit0/d' /etc/init.d/udev
#########################################



#*************************
#*  Application Install  *
#*************************
# Strip out Locale data
RUN for x in `ls /usr/share/locale | grep -v en_GB`; do rm -fr /usr/share/locale/$x; done;
RUN for x in `ls /usr/share/i18n/locales/ | grep -v en_`; do rm -fr $x; done

# Remove Documentation
#RUN find /usr/share/doc -depth -type f ! -name copyright|xargs rm || true && \
#find /usr/share/doc -empty|xargs rmdir || true && \
RUN rm -fr /usr/share/doc/* /usr/share/man/* /usr/share/groff/* /usr/share/info/* && \
rm -rf /usr/share/lintian/* /usr/share/linda/* /var/cache/man/*


# Docker doesn't like the proper way of doing multilined files, so...
RUN echo "# This config file will prevent packages from install docs that are not needed." > /etc/dpkg/dpkg.cfg.d/01_nodoc && \
echo "" >> /etc/dpkg/dpkg.cfg.d/01_nodoc && \
echo "path-exclude /usr/share/doc/*" >> /etc/dpkg/dpkg.cfg.d/01_nodoc && \
echo "# we need to keep copyright files for legal reasons" >> /etc/dpkg/dpkg.cfg.d/01_nodoc && \
echo "# path-include /usr/share/doc/*/copyright" >> /etc/dpkg/dpkg.cfg.d/01_nodoc && \
echo "path-exclude /usr/share/man/*" >> /etc/dpkg/dpkg.cfg.d/01_nodoc && \
echo "path-exclude /usr/share/groff/*" >> /etc/dpkg/dpkg.cfg.d/01_nodoc && \
echo "path-exclude /usr/share/info/*" >> /etc/dpkg/dpkg.cfg.d/01_nodoc && \
echo "" >> /etc/dpkg/dpkg.cfg.d/01_nodoc && \
echo "# lintian stuff is small, but really unnecessary" >> /etc/dpkg/dpkg.cfg.d/01_nodoc && \
echo "path-exclude /usr/share/lintian/*" >> /etc/dpkg/dpkg.cfg.d/01_nodoc && \
echo "path-exclude /usr/share/linda/*" >> /etc/dpkg/dpkg.cfg.d/01_nodoc

# Remove Non America TimeZone Data
# This can be undone via: wget 'ftp://elsie.nci.nih.gov/pub/tzdata*.tar.gz'
RUN for x in `ls /usr/share/zoneinfo|grep -v America`; do rm -fr $x;done;

# Remove hardware rules (acpi, bluetooth, pci-classes, usb-classes, keyboard)
RUN rm -fr /lib/udev/hwdb.d/*



#************************
#* Post Deploy Clean Up *
#************************



#**************************
#*  Config Startup Items  *
#**************************
CMD /bin/bash


#****************************
#* Expose Applicatoin Ports *
#****************************
# Expose ports to other containers only
