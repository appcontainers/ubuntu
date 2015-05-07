#  Ubuntu 14.04 Trusty Tahr Base Minimal Install - 256.4 MB - Updated 5/6/2015

This container is built from appcontainers/ubuntucore, a bare bones newly created unaltered ubuntu core 14.04 LTS Minimal Installation. No modifications or alterations outside of base were performed. Updates were not even completed. It is literally an install and package container.


># Installation Steps:

##Fix Init System (Systemd incompatability)##
   
   `dpkg-divert --local --rename --add /sbin/initctl && ln -sf /bin/true /sbin/initctl
   dpkg-divert --local --rename /usr/bin/ischroot && ln -sf /bin/true /usr/bin/ischroot`

##Fix the udev upgrade problem when doing an apt-get update##
   
   `sed -i '/###\ END\ INIT\ INFO/a exit\ 0' /etc/init.d/udev`

##Update the base install##
  
   `apt-get clean
   apt-get -y update
   DEBIAN_FRONTEND=noninteractive apt-get -y upgrade`

##Install required packages##

   `apt-get -y install net-tools vim wget openssh-client screen ntp tar git`


##Configure NTP and set it in the bashrc so it runs when the container is started (chkconfig does not work in containers)##

   `ntpdate pool.ntp.org`

   `echo "service ntp start" >> ~/.bashrc
   echo "service rsyslog start" >> ~/.bashrc
   echo "service cron start" >> ~/.bashrc
   echo "source /etc/profile.d/termcolor.sh" >> ~/.bashrc`


##Cleanup (removing the contents of /var/cache/ after a apt-get update##

   `rm -fr /var/cache/*`


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
    #FancyX='\342\234\227'
    #Checkmark='\342\234\223'

    # Add a bright white exit status for the last command
    #PS1="$White\$? "
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
        #PS1+="$Red\\u@\\h $YellowBack DEV $Reset"
    else
        PS1+="$Black $YellowBack $TERMTAG $Reset $Green \\u@\\h"
        #PS1+="$Green\\u@\\h $YellowBack DEV $Reset"
    fi
    # Print the working directory and prompt marker in blue, and reset
    # the text color to the default.
    PS1+="$Blue\\w \\\$$Reset "
    }
    
    PROMPT_COMMAND='set_prompt'
    fi

##change the /etc/init.d/udev file back to default (the fix to perform an apt-get upgrade)
   `sed -i '/exit0/d' /etc/init.d/udev`

##Set Dockerfile Runtime command (default command to run when lauched via docker run)##
    
    CMD /bin/bash

># Building the image from the Dockerfile:
    
   `docker build -t appcontainers/ubuntubuild .`


># Packaging the final image

Because we want to make this image as light weight as possible in terms of size, the image is flattened in order to remove the docker build tree, removing any intermediary build containers from the image. In order to remove the reversion history, the image needs to be ran, and then exported/imported. Note that just saving the image will not remove the revision history, In order to remove the revision history, the running container must be exported and then re-imported. 

##Flatten##

>###### Run the build container

    docker run -it \
    --name ubuntubuild \
    -h ubuntubuild  \
    appcontainers/ubuntubuild \
    /bin/bash
 
   
###### The above will bring you into a running shell, because this image was built to start crond, rsyslog, and ntpd, we will want to stop those services before repackaging the image. 


   `service cron stop; service ntp stop; service rsyslog stop`

##### Last lets remove some unneeded documentation.
   `rm -fr /usr/share/doc/* /usr/share/doc-base/* /usr/share/man/* /usr/share/X11/ /usr/share/info/*`

>###### Detach from the container
    
   `CTL P` + `CTL Q`


###### Export and Reimport the Container note that because we started the build container with the name of ubuntubuild, we will use that in the export statement instead of the container ID.

    
   `docker export ubuntubuild | docker import - appcontainers/ubuntu1404`

># Verify

Issuing a `docker images` should now show a newly saved appcontainers/ubuntu1404 images, which can be pushed to the docker hub.

># Running the container
    
   `docker run -it -d appcontainers/ubuntu1404`

># Dockerfile Changelog
    
    05-06-2015 - Image Created.
