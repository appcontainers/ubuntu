**Ubuntu 14.04 Trusty Tahr Base Minimal Install - 117 MB - Updated 7/4/2015**

#  Ubuntu 14.04 Trusty Tahr Base Minimal Install - 117 MB - Updated 5/6/2015

***This container is built from ubuntu:latest, (188 MB Before Flatification)***


># Installation Steps:

##Turn on Apt Progress Output##
   
    echo 'Dpkg::Progress-Fancy "1";' | tee -a /etc/apt/apt.conf.d/99progressbar

##Install required packages##

    DEBIAN_FRONTEND=noninteractive apt-get -y install nano

##Remove un-necessary packages##
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
    
    DEBIAN_FRONTEND=noninteractive apt-get -y autoremove


##Strip out extra non english locale data##

    for x in `ls /usr/share/locale | grep -v en_GB`; do rm -fr /usr/share/locale/$x; done;
    for x in `ls /usr/share/i18n/locales/ | grep -v en_`; do rm -fr $x; done


##Remove Man Pages and Docs to preserve Space##

    rm -fr /usr/share/doc/* /usr/share/man/* /usr/share/groff/* /usr/share/info/*
    rm -rf /usr/share/lintian/* /usr/share/linda/* /var/cache/man/*


##Set documentation generation to off for future installed packages##
       
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

##Remove Time Zone Data Other than America##

This can be undone via: wget 'ftp://elsie.nci.nih.gov/pub/tzdata*.tar.gz'
   
    for x in `ls /usr/share/zoneinfo|grep -v America`; do rm -fr $x;done;

##Remove HW Rules (ACPI, Bluetooth, USB##
rm -fr /lib/udev/hwdb.d/*


##Copy the included Terminal CLI Color Scheme file to /etc/profile.d so that the terminal color will be included in all child images##

    if [ "$PS1" ]; then
    set_prompt () {
    Last_Command=$? # Must come first!
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

    # If it was successful, print a green check mark. Otherwise, print
    # a red X.
    if [[ $Last_Command == 0 ]]; then
        PS1="$Green$Checkmark "
    else
        PS1="$Red$FancyX "
    fi
    # If root, just print the host in red. Otherwise, print the current user
    # and host in green.
    if [[ $EUID == 0 ]]; then
        PS1+="$Black $YellowBack $TERMTAG $Reset $Red \\u@\\h"
    else
        PS1+="$Black $YellowBack $TERMTAG $Reset $Green \\u@\\h"
    fi
    # Print the working directory and prompt marker in blue, and reset
    # the text color to the default.
    PS1+="$Blue\\w \\\$$Reset "
    }
    
    PROMPT_COMMAND='set_prompt'
    fi

##Set Dockerfile Runtime command (default command to run when lauched via docker run)##
    
    CMD /bin/bash

># Building the image from the Dockerfile:
    
   `docker build -t build/ubuntu .`


># Packaging the final image

Because we want to make this image as light weight as possible in terms of size, the image is flattened in order to remove the docker build tree, removing any intermediary build containers from the image. In order to remove the reversion history, the image needs to be ran, and then exported/imported. Note that just saving the image will not remove the revision history, In order to remove the revision history, the running container must be exported and then re-imported. 

##Flatten##

>###### Run the build container

    docker run -it \
    --name ubuntubuild \
    -h ubuntubuild  \
    build/ubuntu \
    /bin/bash
 
   
###### The above will bring you into a running shell, So Detach from the container
    
   `CTL P` + `CTL Q`


###### Export and Reimport the Container note that because we started the build container with the name of ubnutubuild, we will use that in the export statement instead of the container ID.

    
    docker export ubuntubuild | docker import - appcontainers/ubuntu:latest

># Verify

Issuing a `docker images` should now show a newly saved appcontainers/ubuntu image, which can be pushed to the docker hub.

># Running the container
    
   `docker run -it -d appcontainers/ubuntu`


># Dockerfile Changelog
    
    07/04/2015 - Switched from Ubuntu Core, to Docker Hubs library/ubuntu.. Cleanup Image, shrank from 209MB to 117MB

    05/06/2015 - Image Created.
