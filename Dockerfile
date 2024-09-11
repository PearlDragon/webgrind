FROM php:7.4-apache AS builder

COPY . /build

RUN apt-get update \
    && apt-get install -y build-essential zlib1g-dev \
    && cd /build \
    && make \
    && sed 's/\(^ *\)\/\/\(.*DOCKER:ENABLE\)/\1\2/g' config.php > config-docker.php

FROM php:7.4-apache

ENV APACHE_DOCUMENT_ROOT /var/www/grind

RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

RUN apt-get update \
    && apt-get install -y graphviz python3 \
    && rm -rf /var/lib/apt/lists/*

COPY . /var/www/grind
COPY --from=builder /build/bin/preprocessor /var/www/grind/bin/preprocessor
COPY --from=builder /build/config-docker.php /var/www/grind/config.php

WORKDIR /var/www/grind

VOLUME /var/www/html
