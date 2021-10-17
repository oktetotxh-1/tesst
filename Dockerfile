FROM ubuntu:18.04

# necessary envs
ENV container docker
ARG LC_ALL=C
ARG DEBIAN_FRONTEND=noninteractive

# modify source.list
RUN sed -i 's/# deb/deb/g' /etc/apt/sources.list \
    && sed -i 's/archive.ubuntu.com/mirrors.163.com/g' /etc/apt/sources.list

# install systemd and ssh
RUN apt-get update \
    && apt-get install -y systemd ubuntu-minimal \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# remove unnecessary units
RUN rm -f /lib/systemd/system/sysinit.target.wants/*.mount \
    && systemctl disable networkd-dispatcher.service

RUN apt update
RUN apt install ssh wget npm -y
RUN  npm install -g wstunnel
RUN mkdir /run/sshd 
RUN wstunnel -s 0.0.0.0:80 &
RUN whereis sshd
RUN whereis init
RUN /usr/sbin/sshd -D
RUN echo 'PermitRootLogin yes' >>  /etc/ssh/sshd_config 
RUN echo root:tixiaohan|chpasswd
STOPSIGNAL SIGRTMIN+3
WORKDIR /
VOLUME ["/sys/fs/cgroup", "/tmp", "/run", "/run/lock"]
EXPOSE 80
CMD ["/sbin/init"]
