# This build script will create the docker images for the Ubuntun 14.04, 16.04, and 17.04 Linux Base Images
# 2 Images will be created for each version, one bare, and the other including Ansible

# CD into the Main Project directory before launching this script

# Ubuntu 14.04 Base Container Image
cd trusty_tahr/base
docker build -t build/ubuntu .
docker run -it -d --name ubuntu build/ubuntu /bin/bash
docker export ubuntu | docker import - appcontainers/ubuntu:trusty
docker kill ubuntu; docker rm ubuntu
docker push "appcontainers/ubuntu:trusty"
docker images
docker rmi build/ubuntu
docker rmi "appcontainers/ubuntu:trusty"

# Ubuntu 14.04 Base Container Image with Ansible
cd ../ansible
docker build -t build/ubuntu .
docker run -it -d --name ubuntu build/ubuntu /bin/bash
docker export ubuntu | docker import - appcontainers/ubuntu:ansible-trusty
docker kill ubuntu; docker rm ubuntu
docker push "appcontainers/ubuntu:ansible-trusty"
docker images
docker rmi build/ubuntu
docker rmi "appcontainers/ubuntu:ansible-trusty"
docker rmi "ubuntu:trusty"

# Ubuntu 16.04 Base Container Image
cd ../../xenial_xerus/base
docker build -t build/ubuntu .
docker run -it -d --name ubuntu build/ubuntu /bin/bash
docker export ubuntu | docker import - appcontainers/ubuntu:latest
docker tag "appcontainers/ubuntu:latest" "appcontainers/ubuntu:xenial"
docker kill ubuntu; docker rm ubuntu
docker push "appcontainers/ubuntu:latest"
docker push "appcontainers/ubuntu:xenial"
docker images
docker rmi build/ubuntu
docker rmi "appcontainers/ubuntu:latest"
docker rmi "appcontainers/ubuntu:xenial"

# Ubuntu 16.04 Base Container Image with Ansible
cd ../ansible
docker build -t build/ubuntu .
docker run -it -d --name ubuntu build/ubuntu /bin/bash
docker export ubuntu | docker import - appcontainers/ubuntu:ansible
docker tag "appcontainers/ubuntu:ansible" "appcontainers/ubuntu:ansible-xenial"
docker kill ubuntu; docker rm ubuntu
docker push "appcontainers/ubuntu:ansible"
docker push "appcontainers/ubuntu:ansible-xenial"
docker images
docker rmi build/ubuntu
docker rmi "appcontainers/ubuntu:ansible-xenial"
docker rmi "appcontainers/ubuntu:ansible"
docker rmi "ubuntu:16.04"

# Ubuntu 17.04 Base Container Image
cd ../../zesty_zapus/base
docker build -t build/ubuntu .
docker run -it -d --name ubuntu build/ubuntu /bin/bash
docker export ubuntu | docker import - appcontainers/ubuntu:zesty
docker kill ubuntu; docker rm ubuntu
docker push "appcontainers/ubuntu:zesty"
docker images
docker rmi build/ubuntu
docker rmi "appcontainers/ubuntu:zesty"

# Ubuntu 17.04 Base Container Image with Ansible
cd ../ansible
docker build -t build/ubuntu .
docker run -it -d --name ubuntu build/ubuntu /bin/bash
docker export ubuntu | docker import - appcontainers/ubuntu:ansible-zesty
docker kill ubuntu; docker rm ubuntu
docker push "appcontainers/ubuntu:ansible-zesty"
docker images
docker rmi build/ubuntu
docker rmi "appcontainers/ubuntu:ansible-zesty"
docker rmi "ubuntu:17.04"