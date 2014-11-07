>  Modifications from Raw Minimal Installation Base:

 **Install required packages**

    yum -y install net-tools vim-enhanced wget openssh-clients nfs-utils screen yum-utils ntp tar

  **Install the Epel, Remi, and Postgres 9.3 Repositories.**

    cd /etc/yum.repos.d/
    wget http://dl.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm
    wget http://rpms.famillecollet.com/enterprise/remi-release-6.rpm
    rpm -Uvh remi-release-6*.rpm epel-release-6*.rpm

**Modify Remi Repo to include PHP 5.5**

Enable base and PHP 5.5 in Remi

**Install the Postres 9.3 Repository**
       
    rpm -ivh http://yum.postgresql.org/9.3/redhat/rhel-6-x86_64/pgdg-centos93-9.3-1.noarch.rpm

**Configure SSH**

    vim /etc/ssh/sshd_config 
    UseDNS no
    GSSAPIAuthentication no

**Configure SELinux**
    
    vim /etc/sysconfig/selinux
    selinux = disabled

**Turn off IPTables**
    
    chkconfig iptables off
    chkconfig ip6tables off

**Configure NTP and set it in the bashrc so it runs when the container is started (chkconfig does not work in containers)**

    ntpdate pool.ntp.org
    echo "service ntpd start" >> ~/.bashrc
    echo "service rsyslog start" >> ~/.bashrc
    echo "service crond start" >> ~/.bashrc

**Update the OS** 

    yum -y update

**Cleanup**

    rm -f /etc/yum.repos.d/*.rpm
    rm -fr /var/cache/*

**Flatten**

    docker export c30e102f7c51 | docker import - appcontainers/cent65