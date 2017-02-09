FROM ubuntu:16.10
MAINTAINER Rafael Belliard <me@rebelliard.com>

ENV POSTGIS_MAJOR 2.3
ENV PG_MAJOR 9.6

RUN apt-get update -y && \
    apt-get install -y curl && \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb http://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y apt-utils sudo zsh wget curl sudo vim && \
    apt-get install -y \
      build-essential iptables git mercurial python-dev screen \
      rubygems npm nodejs nodejs-legacy awscli yarn \
      postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR postgresql-plpython-$PG_MAJOR \
      python-psycopg2 python-mysqldb \
      memcached libmemcached-dev libmemcache-dev \
      python-setuptools python-dev python-pgmagick \
      python-pip python-geoip \
      libgeos-c1v5 libgeos-dev libgdal-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/* /var/tmp/*

RUN pip install virtualenv virtualenvwrapper --no-cache-dir

RUN pip install --upgrade pip --no-cache-dir

RUN npm install -g bower grunt-cli gulp less@1.7.5 && \
    npm cache clean

CMD /bin/bash

EXPOSE 8000
