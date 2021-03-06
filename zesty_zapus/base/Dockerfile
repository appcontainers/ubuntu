###########################################################
# Dockerfile to build the Ubuntu 17.04 Base Container
# Based on: ubuntu:17.04
# DATE: 07/07/15
# COPYRIGHT: Appcontainers.com
###########################################################

# Set the base image in namespace/repo format.
# To use repos that are not on the docker hub use the example.com/namespace/repo format.
FROM library/ubuntu:17.04

# File Author / Maintainer
MAINTAINER Rich Nason rnason@appcontainers.com

###########################################################
#*********************  APP VERSIONS  *********************
###########################################################


###########################################################
#***********  OVERRIDE ENABLED ENV VARIABLES  *************
###########################################################

ENV TERMTAG UbuntuZestyBase

###########################################################
#**************  ADD REQUIRED APP FILES  ******************
###########################################################

# Enable Progress Bar
RUN echo 'Dpkg::Progress-Fancy "1";' | tee -a /etc/apt/apt.conf.d/99progressbar

###########################################################
#***************  UPDATES & PRE-REQS  *********************
###########################################################

# Update, Upgrade, and Install nano.
RUN apt-get clean && \
apt-get update && \
apt-get -y upgrade && \
DEBIAN_FRONTEND=noninteractive apt-get -y install apt-utils && \
apt-get -y upgrade

###########################################################
#***************  APPLICATION INSTALL  ********************
###########################################################

# Get rid of some un-needed packages.
RUN DEBIAN_FRONTEND=noninteractive apt-get -y purge \
ubuntu-minimal \
eject \
isc-dhcp-common \
isc-dhcp-client \
kbd \
console-setup \
xkb-data \
bzip2 \
python3.4 \
python3-minimal \
keyboard-configuration && \
DEBIAN_FRONTEND=noninteractive apt-get -y autoremove && \
apt-get clean && \
rm -fr /var/lib/apt/lists/*

# Clean up after the python install
RUN rm -fr /usr/share/dh-python/

###########################################################
#**************  POST DEPLOY CLEAN UP  ********************
###########################################################

# Strip out Locale data
RUN for x in `ls /usr/share/locale | grep -v en_GB`; do rm -fr /usr/share/locale/$x; done;
RUN for x in `ls /usr/share/i18n/locales/ | grep -v en_`; do rm -fr /usr/share/i18n/locales/$x; done

# Remove Documentation
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

# Set the default Timezone to EST
RUN cp /etc/localtime /root/old.timezone | exit 0 && \
rm -f /etc/localtime | exit 0 && \
ln -s /usr/share/zoneinfo/America/New_York /etc/localtime | exit 0

# Disable IPV6
RUN echo "net.ipv6.conf.all.disable_ipv6=1" > /etc/sysctl.d/disableipv6.conf && \
echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf && \
echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf && \
echo "net.ipv6.conf.lo.disable_ipv6 = 1" >> /etc/sysctl.conf && \
echo "net.ipv6.conf.eth0.disable_ipv6 = 1" >> /etc/sysctl.conf && \
echo "net.ipv6.conf.eth1.disable_ipv6 = 1" >> /etc/sysctl.conf

###########################################################
#*************  CONFIGURE START ITEMS  ********************
###########################################################

ADD termcolor.sh /etc/profile.d/PS1.sh
RUN chmod +x /etc/profile.d/PS1.sh && \
echo "source /etc/profile.d/PS1.sh" >> /root/.bashrc && \
echo "source /etc/profile.d/PS1.sh" >> /etc/skel/.bashrc
# echo "alias vim='nano'" >> /root/.bashrc

# Add the following to prevent any additions to the .bashrc from being executed via SSH or SCP sessions
RUN echo "\nif [[ -n \"\$SSH_CLIENT\" || -n \"\$SSH_TTY\" ]]; then\n\treturn;\nfi\n" >> /root/.bashrc && \
echo "\nif [[ -n \"\$SSH_CLIENT\" || -n \"\$SSH_TTY\" ]]; then\n\treturn;\nfi\n" >> /etc/skel/.bashrc

CMD /bin/bash

###########################################################
#****************  EXPOSE APPLICATION PORTS  **********************
###########################################################


###########################################################
#*******************  OPTIONAL / LEGACY  **************************
###########################################################
