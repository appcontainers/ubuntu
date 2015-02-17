############################################################
# Dockerfile to build the CentOS65 Base Container
# Based on appcontainers/centos66base
############################################################

# Set the base image to Centos66 Base
FROM appcontainers/centos66base

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
# Install wget and other utils, wget is required for installing epel and remi repos
RUN yum -y install net-tools vim-enhanced wget openssh-clients nfs-utils screen yum-utils ntp tar git && \
rm -fr /var/cache/*

# Download and install Epel, Remi, and the Postgres 9.3 repositories.
RUN cd /etc/yum.repos.d/ && \
wget http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm && \
wget http://rpms.famillecollet.com/enterprise/remi-release-6.rpm && \
rpm -Uvh remi-release-6*.rpm epel-release-6*.rpm && \
rpm -ivh http://yum.postgresql.org/9.3/redhat/rhel-6-x86_64/pgdg-centos93-9.3-1.noarch.rpm && \
rm -fr *.rpm

#Enable the remi repo
RUN sed -ie '/\[remi\]/,/^\[/s/enabled=0/enabled=1/' /etc/yum.repos.d/remi.repo && \
sed -ie '/\[remi-php55\]/,/^\[/s/enabled=0/enabled=1/' /etc/yum.repos.d/remi.repo

#*************************
#*  Update and Pre-Reqs  *
#*************************
RUN yum clean all && \
yum -y update && \
# Fix Passwd functionality
rpm -e cracklib-dicts --nodeps && \
yum -y install cracklib-dicts && \
rm -fr /var/cache/*


#*************************
#*  Application Install  *
#*************************
# Modify SSH and SELinux
RUN sed -ie 's/#UseDNS\ yes/UseDNS\ no/g' /etc/ssh/sshd_config && \
sed -ie 's/GSSAPIAuthentication\ yes /GSSAPIAuthentication\ no/g' /etc/ssh/sshd_config && \
sed -ie 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
ADD termcolor.sh /etc/profile.d/

#************************
#* Post Deploy Clean Up *
#************************
# Set NTP
RUN ntpdate pool.ntp.org


#**************************
#*  Config Startup Items  *
#**************************
RUN echo "service ntpd start" >> ~/.bashrc && \
echo "service rsyslog start" >> ~/.bashrc && \
echo "service crond start" >> ~/.bashrc

CMD /bin/bash

#****************************
#* Expose Applicatoin Ports *
#****************************
# Expose ports to other containers only
