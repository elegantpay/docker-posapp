# app server, base centos6
# include sshd, java, node.js, supervisord

FROM centos:6
MAINTAINER yinheli <me@yinheli.com>

# install base util
RUN yum install -y wget tar

### install sshd ###

# install sshd
RUN yum install -y openssh-server openssh-clients

RUN ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key && \
    ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key

# fix the 254 error code
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config && \
    sed -ri 's/#UsePAM no/UsePAM no/g' /etc/ssh/sshd_config

# default password
RUN /bin/echo 'root:henry!123qwe'|chpasswd

# install git
RUN yum install -y git



### install java ###

# download && install java
RUN wget --progress=bar --no-check-certificate \
    -O /tmp/jdk.tar.gz \
    --header "Cookie: oraclelicense=a" \
    http://download.oracle.com/otn-pub/java/jdk/8u31-b13/jdk-8u31-linux-x64.tar.gz && \
    tar xzf /tmp/jdk.tar.gz && \
    mkdir -p /usr/local/jdk && \
    mv jdk1.8.0_31/* /usr/local/jdk/ && \
    rm -rf jdk1.8.0_31 && rm -f /tmp/jdk.tar.gz && \
    chown root:root -R /usr/local/jdk && \
    update-alternatives --install /usr/bin/java java /usr/local/jdk/bin/java 1 && \
    update-alternatives --set java /usr/local/jdk/bin/java

ENV JAVA_HOME /usr/local/jdk



### install node.js ###

RUN rm -rf ~/.nvm && git clone https://github.com/creationix/nvm.git ~/.nvm && \
    cd ~/.nvm && git checkout `git describe --abbrev=0 --tags`
RUN source ~/.nvm/nvm.sh && \
    echo 'source ~/.nvm/nvm.sh' >> ~/.bash_profile && \
    nvm install v0.10.32 && \
    nvm alias default 0.10.32



### install supervisord

RUN yum install -y python-setuptools && easy_install pip && pip install supervisor

COPY supervisord.conf /etc/supervisord.conf


### other ###

# set env
ENV PATH $PATH:$JAVA_HOME/bin

EXPOSE 22


CMD ["/usr/bin/supervisord"]
