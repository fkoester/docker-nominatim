FROM debian:jessie
MAINTAINER Fabian Köster <mail@fabian-koester.com>

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    apache2 \
    build-essential \
    curl \
    libapache2-mod-php5 \
    libboost-dev \
    libboost-filesystem-dev \
    libboost-system-dev \
    libboost-thread-dev \
    libbz2-dev \
    libexpat-dev \
    libgeos-c1 \
    libgeos++-dev \
    libpq-dev \
    libproj-dev \
    libtool \
    libxml2-dev \
    php-db \
    php5 \
    php5-json \
    php5-pgsql \
    php-pear \
    postgresql-client \
    postgresql-server-dev-9.4 \
    proj-bin \
 && rm -rf /var/lib/apt/lists/*

ARG WEBROOT=/var/www/html/nominatim
RUN groupadd -r nominatim && useradd -r -g nominatim nominatim
RUN mkdir -m 755 ${WEBROOT} && chown -R nominatim:nominatim ${WEBROOT}
USER nominatim

WORKDIR /app
ARG NOMINATIM_VERSION=2.5.1
ARG RELEASE_SHA256=0c2d7fcafc3caa42b3f5f2041ecf33bb22377ffe861a0b97a5aa27b6552d597b
RUN curl -o nominatim.tar.bz2 http://www.nominatim.org/release/Nominatim-${NOMINATIM_VERSION}.tar.bz2 \
  && echo "${RELEASE_SHA256} nominatim.tar.bz2" | sha256sum -c \
  && tar -xf nominatim.tar.bz2 --strip-components=1 \
  && rm *.tar.bz2 \
  && ./configure \
  && make

COPY wait-for-it.sh .
COPY entrypoint.sh .
COPY local.php ./settings/local.php
COPY apache.conf /etc/apache2/sites-available/000-default.conf
COPY apache2-foreground /usr/local/bin

VOLUME /importdata
CMD /app/entrypoint.sh
