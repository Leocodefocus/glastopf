FROM ubuntu:18.04
MAINTAINER Lukas Rist <glaslos@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

## setup APT
RUN sed -i '1ideb mirror://mirrors.ubuntu.com/mirrors.txt trusty main restricted universe multiverse' /etc/apt/sources.list && \
    sed -i '1ideb mirror://mirrors.ubuntu.com/mirrors.txt trusty-updates main restricted universe multiverse' /etc/apt/sources.list && \
    sed -i '1ideb mirror://mirrors.ubuntu.com/mirrors.txt trusty-backports main restricted universe multiverse' /etc/apt/sources.list && \
    sed -i '1ideb mirror://mirrors.ubuntu.com/mirrors.txt trusty-security main restricted universe multiverse' /etc/apt/sources.list

## Install dependencies
RUN apt-get update && apt-get install -y \
        build-essential \
        g++ \
        gfortran \
        git \
        libevent-dev \
        liblapack-dev \
        libmysqlclient-dev \
        libxml2-dev \
        libxslt-dev \
        make \
        python-beautifulsoup \
        python-chardet \
        python-dev \
        python-gevent \
        python-lxml \
        python-openssl \
        python-pip \
        python-requests \
        python-setuptools \
        python-sqlalchemy \
        python-mysqldb \
        cython \
        python-dateutil \
        python2.7 \
        python2.7-dev \
        software-properties-common \
	dirmngr \
	apt-transport-https \
	lsb-release \
	ca-certificates \
	&& \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#RUN locale-gen en_US.UTF-8
RUN export LANG=en_US.UTF-8
RUN LC_ALL=en_US.UTF-8 add-apt-repository -y ppa:ondrej/php && apt-get update

RUN apt-get install -y --force-yes  php7.0 php7.0-dev

## Install and configure the PHP sandbox
RUN rm -rf /opt/BFR
#RUN mkdir /opt/BFR
RUN git clone https://github.com/mushorg/BFR.git /opt/BFR
RUN cd /opt/BFR && phpize7.0 && ./configure --enable-bfr \
	&& make && make install
RUN echo "zend_extension = "$(find /usr -name bfr.so) >> /etc/php/7.0/cli/php.ini
RUN rm -rf /opt/BFR /tmp/* /var/tmp/*


## Install glastopf from latest sources
RUN pip install git+https://github.com/mushorg/glastopf
#RUN rm -rf /opt/glastopf
#RUN mkdir /opt/glastopf
#RUN git clone https://github.com/mushorg/glastopf.git /opt/glastopf && cd /opt/glastopf && python setup.py install
#RUN rm -rf /opt/glastopf /tmp/* /var/tmp/*

## Configuration
RUN mkdir /opt/myhoneypot

EXPOSE 80
WORKDIR /opt/myhoneypot
CMD ["glastopf-runner"]
