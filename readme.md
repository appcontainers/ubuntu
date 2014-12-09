#  CentOS 6.6 Base Minimal Install - 242.7 MB - Built 11/2014

This container is built from appcontainers/centos66base, a bare bones newly created unaltered CentOS 6.6 Minimal Installation. No modifications or alterations outside of base were performed. Updates were not even completed. It is literally an install and package container.


>## Installation Steps:

*Install required packages*

    yum -y install net-tools vim-enhanced wget openssh-clients nfs-utils screen yum-utils ntp tar

*Install the Epel, Remi, and Postgres 9.3 Repositories.*

    cd /etc/yum.repos.d/
    wget http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
    wget http://rpms.famillecollet.com/enterprise/remi-release-6.rpm
    rpm -Uvh remi-release-6*.rpm epel-release-6*.rpm`

*Modify Remi Repo to enable remi base and PHP 5.5*

    sed -ie '/\[remi\]/,/^\[/s/enabled=0/enabled=1/' /etc/yum.repos.d/remi.repo
    sed -ie '/\[remi-php55\]/,/^\[/s/enabled=0/enabled=1/' /etc/yum.repos.d/remi.repo`

*Install the Postres 9.3 Repository*
       
    rpm -ivh http://yum.postgresql.org/9.3/redhat/rhel-6-x86_64/pgdg-centos93-9.3-1.noarch.rpm

*Configure SSH (disabled by default, just setting parameters, in the event an image will use it)*

`vim /etc/ssh/sshd_config `

    UseDNS no
    GSSAPIAuthentication no

*Configure SELinux*
    
`vim /etc/sysconfig/selinux`

    selinux = disabled

*Turn off IPTables*
    
`chkconfig iptables off; chkconfig ip6tables off`

*Configure NTP and set it in the bashrc so it runs when the container is started (chkconfig does not work in containers)*

`ntpdate pool.ntp.org`

    echo "service ntpd start" >> ~/.bashrc
    echo "service rsyslog start" >> ~/.bashrc
    echo "service crond start" >> ~/.bashrc`

*Update the OS*

`yum -y update`

*Cleanup (removing the contents of /var/cache/ after a yum update or yum install will save about 150MB from the image*

`rm -f /etc/yum.repos.d/*.rpm; rm -fr /var/cache/*`

*Set Runtime Variable (default command to run when lauched via docker run)*
    
    CMD /bin/bash


>## Building the image from the dockerfile:
    
`docker build -t appcontainers/centos66build .`


>## Packaging the final image

Because we want to make this image as light weight as possible in terms of size, the image is flattened in order to remove the docker build tree, removing any intermediary build containers from the image. In order to remove the reversion history, the image needs to be ran, and then exported/imported. Note that just saving the image will not remove the revision history, In order to remove the revision history, the running container must be exported and then re-imported. 

*Flatten*

>###### Run the build container

    docker run -it \
    --name centos66build \
    -h centos66build  \
    appcontainers/centos66build \
    /bin/bash
    
>###### The above will bring you into a running shell, because this image was built to start crond, rsyslog, and ntpd, we will want to stop those services before repackaging the image. 

`service crond stop; service ntpd stop; service rsyslog stop`

>###### Detach from the container
    
`CTL P` + `CTL Q`

> Export and Reimport the Container note that because we started the build container with the name of cenots66build, we will use that in the export statement instead of the container ID.
    
`docker export centos66build | docker import - appcontainers/centos66`

>## Verify

Issuing a `docker images` should now show a newly saved appcontainers/centos66 images, which can be pushed to the docker hub.

>## Running the container
    
`docker run -it -d appcontainers/centos66`