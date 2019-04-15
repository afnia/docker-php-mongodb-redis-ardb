FROM afnia/alpine-ardb

ENV PHPIZE_DEPS \ 
    autoconf \
    g++ \ 
    gcc \ 
    make \ 
    pkgconf

RUN apk update && apk --no-cache add supervisor nginx curl openssl-dev openssh-client
RUN apk add --no-cache php7 php7-fpm php7-json php7-openssl php7-curl \
    php7-xml php7-phar php7-intl php7-xmlreader php7-ctype \
    php7-mbstring php7-gd php7-pear php7-dev php-intl $PHPIZE_DEPS && \
    pecl install mongodb \
    pecl clear-cache && \
    apk --repository http://dl-3.alpinelinux.org/alpine/edge/testing/ --update add git rsync && \
    apk add py-pip; pip install redis;

ARG BUILD_DATE
ARG VCS_REF
ARG REDIS_RELEASE

LABEL org.label-schema.build-date=$BUILD_DATE\
      org.label-schema.version=$REDIS_RELEASE\
      org.label-schema.vcs-url="https://github.com/comodal/alpine-redis.git"\
      org.label-schema.vcs-ref=$VCS_REF\
      org.label-schema.name="Redis Alpine Image"\
      org.label-schema.usage="https://github.com/comodal/alpine-redis#docker-run"\
      org.label-schema.schema-version="1.0.0-rc.1"

RUN addgroup -S redis && adduser -S -G redis redis\
 && mkdir -p /redis/data /redis/modules\
 && chown redis:redis /redis/data /redis/modules

RUN set -x\
 && apk add --no-cache --virtual .build-deps\
  curl\
  gcc\
  linux-headers\
  make\
  musl-dev\
  tar\
 && curl -o redis.tar.gz https://codeload.github.com/antirez/redis/tar.gz/5.0\
 && mkdir -p /usr/src/redis\
 && tar -xzf redis.tar.gz -C /usr/src/redis --strip-components=1\
 && rm redis.tar.gz\
 && make -C /usr/src/redis\
 && make -C /usr/src/redis install\
 && rm -r /usr/src/redis\
 && apk del .build-deps

#RUN apk --repository http://dl-3.alpinelinux.org/alpine/edge/testing/ --update add leveldb leveldb-dev
#RUN pear install http://pecl.php.net/get/leveldb-0.2.1.tgz
#RUN echo 'extension=leveldb.so' >> /etc/php7/php.ini 
