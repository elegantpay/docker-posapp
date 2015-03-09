# app server, base ubuntu
# include sshd, java, node.js, supervisord

FROM ubuntu:14.04
MAINTAINER yinheli <me@yinheli.com>

## install wget tar git sshd
RUN apt-get update && apt-get install -y wget tar git openssh-server supervisor


RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config && \
    sed -ri 's/#UsePAM no/UsePAM no/g' /etc/ssh/sshd_config && \
    sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' /etc/pam.d/sshd && \
    echo "export VISIBLE=now" >> /etc/profile && \
    /bin/echo 'root:henry!123qwe'|chpasswd

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
RUN . ~/.nvm/nvm.sh && \
    echo '. ~/.nvm/nvm.sh' >> ~/.bash_profile && \
    nvm install v0.10.32 && \
    nvm alias default 0.10.32


COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf


### other ###

# set env
ENV PATH $PATH:\$JAVA_HOME/bin

EXPOSE 22


CMD ["/usr/bin/supervisord"]
