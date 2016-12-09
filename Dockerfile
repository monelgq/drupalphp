# 基础镜像
FROM php:7.0-fpm

# 镜像配置目录 【 /usr/local/etc/php/php.ini 】【 /usr/local/etc/php/conf.d 】【 /usr/local/etc/php-fpm.conf 】【 /usr/local/etc/php-fpm.d/www.conf 】

# php配置文件替换修改 
# RUN if [ -f /usr/local/etc/php-fpm.conf ]; then rm /usr/local/etc/php-fpm.conf; fi
COPY config/php-fpm.conf /usr/local/etc/
COPY config/php.ini /usr/local/etc/php/
COPY config/www.conf /usr/local/etc/php-fpm.d/
COPY config/opcache-recommended.ini /usr/local/etc/php/conf.d/

# 安装必要的PHP扩展PHP extensions，参考主机安装
RUN apt-get update && apt-get install -y apt-utils wget git mariadb-client \ 
       libpng12-dev libjpeg-dev libpq-dev libfreetype6-dev libmcrypt-dev libicu-dev zlib1g-dev libmemcached-dev libjpeg62-turbo-dev \ 
       && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-png-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
       && docker-php-ext-install gd opcache pdo_mysql mysqli zip mcrypt bcmath exif sockets calendar intl \
       && rm -rf /var/lib/apt/lists/*
	
# 安装 php7 redis 扩展
ADD https://github.com/phpredis/phpredis/archive/php7.tar.gz /tmp/phpredis.tar.gz
RUN mkdir -p /usr/src/php/ext/redis \
      && tar xf /tmp/phpredis.tar.gz -C /usr/src/php/ext/redis --strip-components=1 \
      && docker-php-ext-install redis \
      && rm -rd /usr/src/php/ext/redis \
      && rm /tmp/phpredis.tar.gz
         
# 设置drupal8版本和MD5校验环境变量以及安装根目录，需要经常更新
ENV DRUPAL_ROOT /var/www/drupal8
ENV DRUPAL_VERSION 8.2.4
ENV DRUPAL_MD5 288aa9978b5027e26f20df93b6295f6c

# 创建容器内部drupal8站点根目录和drupal8源代码下载目录
RUN set -x \
       && mkdir -p ${DRUPAL_ROOT} \
       && mkdir -p /usr/src/drupal8

# 安装 composer，国外网址难于下载，但是在github自动编译没有问题
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# 安装 composer，暂时使用本人的服务器下载
# RUN cd /usr/local/bin \
#        && wget http://133.130.123.167/download/composer.phar \
#        && mv composer.phar composer \
#        && chmod +x /usr/local/bin/composer

# 安装 drush
RUN php -r "readfile('https://s3.amazonaws.com/files.drush.org/drush.phar');" > /usr/local/bin/drush \
       && chmod +x /usr/local/bin/drush

# 下载 drupal8最新版本 
WORKDIR /usr/src/drupal8     
RUN curl -fSL "https://ftp.drupal.org/files/projects/drupal-${DRUPAL_VERSION}.tar.gz" -o drupal.tar.gz \
	&& echo "${DRUPAL_MD5} *drupal.tar.gz" | md5sum -c - \
	&& chown -R www-data:www-data ${DRUPAL_ROOT}

WORKDIR ${DRUPAL_ROOT}

# USER root
# 容器启动时执行容器入口文件
COPY drupalphp-cmd.sh /usr/local/bin/
RUN  chmod +x /usr/local/bin/drupalphp-cmd.sh
CMD ["/usr/local/bin/drupalphp-cmd.sh"]
	