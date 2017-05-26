## Ubuntu 17.04 Zesty Zapus Ansible Base Minimal Install - 218 MB - Updated 05/26/2017 (tags: ansible-zesty)

***This container is built from ubuntu:17.04, (466 MB Before Flatification)***

## Installation Steps:
-------

#### Turn on Apt Progress Output:

```bash
echo 'Dpkg::Progress-Fancy "1";' | tee -a /etc/apt/apt.conf.d/99progressbar
```

<br>

#### Install required packages:

```bash
DEBIAN_FRONTEND=noninteractive apt-get -y install apt-utils curl vim python python-dev python-openssl libffi-dev libssl-dev gcc
apt-get -y upgrade
```

<br>

#### Configure Ansible:

```bash
curl "https://bootstrap.pypa.io/get-pip.py" -o "/tmp/get-pip.py"
python /tmp/get-pip.py
pip install pip ansible --upgrade
rm -fr /tmp/get-pip.py
mkdir -p /etc/ansible/roles || exit 0
echo localhost ansible_connection=local > /etc/ansible/hosts
```

<br>

#### Uninstall un-needed packages:

```bash
apt-get remove -y gcc python-dev libffi-dev libssl-dev
apt-get autoremove -y 
```

<br>

#### Cleanup:

***Remove the contents of /var/lib/apt after a apt update or apt install which will save about 150MB from the image size***

```bash
DEBIAN_FRONTEND=noninteractive apt-get -y purge \
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
```

<br>

#### Cleanup Locales:

```bash
for x in `ls /usr/share/locale | grep -v en_GB`; do rm -fr /usr/share/locale/$x; done;
for x in `ls /usr/share/i18n/locales/ | grep -v en_`; do rm -fr /usr/share/i18n/locales/$x; done;
rm -fr /usr/share/doc/* /usr/share/man/* /usr/share/groff/* /usr/share/info/* /usr/share/lintian/* /usr/share/linda/* /var/cache/man/* /usr/share/dh-python/
```

__Prevent new packages from installing un-needed docs__

```bash
echo "# This config file will prevent packages from install docs that are not needed." > /etc/dpkg/dpkg.cfg.d/01_nodoc && \
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
```

<br>

#### Set the default Timezone to EST:

```bash
cp /etc/localtime /root/old.timezone | exit 0 && \
rm -f /etc/localtime | exit 0 && \
ln -s /usr/share/zoneinfo/America/New_York /etc/localtime | exit 0
```

<br>

#### Disable IPv6:

```bash
echo "net.ipv6.conf.all.disable_ipv6=1" > /etc/sysctl.d/disableipv6.conf && \
echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf && \
echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf && \
echo "net.ipv6.conf.lo.disable_ipv6 = 1" >> /etc/sysctl.conf && \
echo "net.ipv6.conf.eth0.disable_ipv6 = 1" >> /etc/sysctl.conf && \
echo "net.ipv6.conf.eth1.disable_ipv6 = 1" >> /etc/sysctl.conf
```

<br>

#### Set the Terminal CLI Prompt:

***Copy the included Terminal CLI Color Scheme file to /etc/profile.d so that the terminal color will be included in all child images***

```bash
#!/bin/bash
if [ "$PS1" ]; then
    set_prompt () {
    Last_Command=$?
    Blue='\[\e[01;34m\]'
    White='\[\e[01;37m\]'
    Red='\[\e[01;31m\]'
    YellowBack='\[\e[01;43m\]'
    Green='\[\e[01;32m\]'
    Yellow='\[\e[01;33m\]'
    Black='\[\e[01;30m\]'
    Reset='\[\e[00m\]'
    FancyX=':('
    Checkmark=':)'

    # If it was successful, print a green check mark. Otherwise, print a red X.
    if [[ $Last_Command == 0 ]]; then
        PS1="$Green$Checkmark "
    else
        PS1="$Red$FancyX "
    fi
    # If root, just print the host in red. Otherwise, print the current user and host in green.
    if [[ $EUID == 0 ]]; then
        PS1+="$Black $YellowBack $TERMTAG $Reset $Red \\u@\\h"
    else
        PS1+="$Black $YellowBack $TERMTAG $Reset $Green \\u@\\h"
    fi
    # Print the working directory and prompt marker in blue, and reset the text color to the default.
    PS1+="$Blue\\w \\\$$Reset "
    }
    
    PROMPT_COMMAND='set_prompt'
fi
```

<br>

#### Prevent the .bashrc from being executed via SSH or SCP sessions:

```bash
echo -e "\nif [[ -n \"\$SSH_CLIENT\" || -n \"\$SSH_TTY\" ]]; then\n\treturn;\nfi\n" >> /root/.bashrc && \
echo -e "\nif [[ -n \"\$SSH_CLIENT\" || -n \"\$SSH_TTY\" ]]; then\n\treturn;\nfi\n" >> /etc/skel/.bashrc
```

<br>

#### Set Dockerfile Runtime command:

***Default command to run when lauched via docker run***

```bash
CMD /bin/bash
```

<br>

## Dockerfile:
-------

```bash
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
# DEBIAN_FRONTEND=noninteractive apt-get -y install apt-utils curl vim python python-dev python-openssl libffi-dev libssl-dev gcc && \
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

# Install pip and configure ansible
# RUN curl "https://bootstrap.pypa.io/get-pip.py" -o "/tmp/get-pip.py" && \
# python /tmp/get-pip.py && \
# pip install pip ansible --upgrade && \
# rm -fr /tmp/get-pip.py && \
# mkdir -p /etc/ansible/roles || exit 0 && \
# echo localhost ansible_connection=local > /etc/ansible/hosts

###########################################################
#**************  POST DEPLOY CLEAN UP  ********************
###########################################################

# Clean up packages we don't need now that ansible is installed
# RUN apt-get remove -y gcc python-dev libffi-dev libssl-dev && \
# apt-get autoremove -y

# Strip out Locale data
RUN for x in `ls /usr/share/locale | grep -v en_GB`; do rm -fr /usr/share/locale/$x; done;
RUN for x in `ls /usr/share/i18n/locales/ | grep -v en_`; do rm -fr /usr/share/i18n/locales/$x; done

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
#****************  EXPOSE APPLICATION PORTS  **************
###########################################################


###########################################################
#*******************  OPTIONAL / LEGACY  ******************
###########################################################
```

<br>

## Building the image from the Dockerfile:
-------

```bash
docker build -t build/ubuntu .
```

<br>

## Packaging the final image:
-------

Because we want to make this image as light weight as possible in terms of size, the image is flattened in order to remove the docker build tree, removing any intermediary build containers from the image. In order to remove the reversion history, the image needs to be ran, and then exported/imported. Note that just saving the image will not remove the revision history, In order to remove the revision history, the running container must be exported and then re-imported.

<br>

#### Run the container build:

```bash
docker run -it -d \
--name ubuntu \
build/ubuntu \
/bin/bash
```

***The run statement should start a detached container, however if you are attached, detach from the container*** 

`CTL P` + `CTL Q`

<br>

#### Export and Re-import the Container:

__Note that because we started the build container with the name of ubuntu, we will use that in the export statement instead of the container ID.__

```bash
docker export ubuntu | docker import - appcontainers/ubuntu:ansible-zesty
```

<br>

#### Verify:

Issuing a `docker images` should now show a newly saved appcontainers/ubuntu:ansible-zesty image, which can be pushed to the docker hub.

<br>

## Run the container:
-------

```bash
docker run -it -d appcontainers/ubuntu:ansible-zesty
```

<br>

## Dockerfile Change-log:
-------

```buildlog
05/26/2017 - Upated to 17.04 Zesty, fixed /etc/localtime build error
03/25/2017 - Created separate build/tags for raw base and base with ansible installed
03/24/2017 - Update to 8.7
11/28/2016 - Update to 8.6 include python, pip, vim, and ansible to replace custom runconfig
06/11/2016 - Update to 8.3
12/14/2015 - Update to 8.2
09/29/2015 - Add Line to .bashrc to prevent additions to the basrc to be run from SSH/SCP login
08/07/2015 - Turn off IPV6
07/03/2015 - Initial Image Build
```