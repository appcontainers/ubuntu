## Ubuntu 16.04 Xenial Xerus LTS Base Minimal Install - 77 MB - Updated 03/25/2017 (tags: latest, xenial)

***This container is built from ubuntu:16.04, (199 MB Before Flatification)***

>># Installation Steps:

### Turn on Apt Progress Output

```bash
echo 'Dpkg::Progress-Fancy "1";' | tee -a /etc/apt/apt.conf.d/99progressbar
```

### Install required packages

```bash
DEBIAN_FRONTEND=noninteractive apt-get -y install apt-utils
apt-get -y upgrade
```

### Remove un-necessary packages

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
python3.4-minimal \
libpython3-stdlib:amd64 \
libpython3.4-minimal:amd64 \
libpython3.4-stdlib:amd64 \
keyboard-configuration && \

DEBIAN_FRONTEND=noninteractive apt-get -y autoremove
```

### Clean up the python3 uninstall

```bash
rm -fr /usr/share/dh-python/
```

### Strip out extra locale data

```bash
for x in `ls /usr/share/locale | grep -v en_GB`; do rm -fr /usr/share/locale/$x; done;
for x in `ls /usr/share/i18n/locales/ | grep -v en_`; do rm -fr /usr/share/i18n/locales/$x; done
```

### Remove Man Pages and Docs to preserve Space

```bash
rm -fr /usr/share/doc/* /usr/share/man/* /usr/share/groff/* /usr/share/info/*
rm -rf /usr/share/lintian/* /usr/share/linda/* /var/cache/man/*
```

### Set documentation generation to off for future installed packages

```bash
cat > /etc/dpkg/dpkg.cfg.d/01_nodoc << "EOF"
# This config file will prevent packages from install docs that are not needed.
path-exclude /usr/share/doc/*
path-exclude /usr/share/man/*
path-exclude /usr/share/groff/*
path-exclude /usr/share/info/*
# lintian stuff is small, but really unnecessary
path-exclude /usr/share/lintian/*
path-exclude /usr/share/linda/*
EOF
```

### Set Time Zone to EST (America/New_York)

```bash
cp /etc/localtime /root/old.timezone && \
rm -f /etc/localtime && \
ln -s /usr/share/zoneinfo/America/New_York /etc/localtime
```

### Turn off IPV6

```bash
echo "net.ipv6.conf.all.disable_ipv6=1" > /etc/sysctl.d/disableipv6.conf && \
echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf && \
echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf && \
echo "net.ipv6.conf.lo.disable_ipv6 = 1" >> /etc/sysctl.conf && \
echo "net.ipv6.conf.eth0.disable_ipv6 = 1" >> /etc/sysctl.conf && \
echo "net.ipv6.conf.eth1.disable_ipv6 = 1" >> /etc/sysctl.conf
```

### Set the Terminal CLI Prompt

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

### Prevent the .bashrc from being executed via SSH or SCP sessions

```bash
echo -e "\nif [[ -n \"\$SSH_CLIENT\" || -n \"\$SSH_TTY\" ]]; then\n\treturn;\nfi\n" >> /root/.bashrc && \
echo -e "\nif [[ -n \"\$SSH_CLIENT\" || -n \"\$SSH_TTY\" ]]; then\n\treturn;\nfi\n" >> /etc/skel/.bashrc
```

### Set Dockerfile Runtime command

***Default command to run when lauched via docker run***

```bash
CMD /bin/bash
```
&nbsp;

># Building the image from the Dockerfile:

```bash
docker build -t build/ubuntu .
```
&nbsp;

># Packaging the final image

Because we want to make this image as light weight as possible in terms of size, the image is flattened in order to remove the docker build tree, removing any intermediary build containers from the image. In order to remove the reversion history, the image needs to be ran, and then exported/imported. Note that just saving the image will not remove the revision history, In order to remove the revision history, the running container must be exported and then re-imported.

&nbsp;

># Flatten the Image

***Run the build container***

```bash
docker run -it -d \
--name ubuntu \
build/ubuntu \
/bin/bash
```

***The run statement should start a detached container, however if you are attached, detach from the container***

`CTL P` + `CTL Q`

***Export and Re-import the Container***

__Note that because we started the build container with the name of ubuntu, we will use that in the export statement instead of the container ID.__

```bash
docker export ubuntu | docker import - appcontainers/ubuntu:xenial
```

***Verify***

Issuing a `docker images` should now show a newly saved appcontainers/ubuntu:xenial image, which can be pushed to the docker hub.

***Run the container***

```bash
docker run -it -d appcontainers/ubuntu:xenial
```

&nbsp;

># Dockerfile Changelog:

    03/25/2017 - Created separate build/tags for raw base and base with ansible installed
    03/24/2017 - Rebuild of Xenial to replace Trusty as LTS lastest
    11/28/2016 - Replaced Xerus with 16.10 Yakkety Yak, added vim, python, pip, ansible to replace runconfig custom script
    06/11/2016 - Replaced Wily with 16.04 Xenial Xerus
    12/14/2015 - Replaced Vivid with 15.10 Wily
    09/29/2015 - Add Line to .bashrc to prevent additions to the basrc to be run from SSH/SCP login
    08/07/2015 - Updated image, set to tag latest, disable IPV6.
    07/07/2015 - Image Created.
