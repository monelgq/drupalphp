# 基础镜像
FROM php:7.3-fpm

# 镜像配置目录 【 /usr/local/etc/php/php.ini 】【 /usr/local/etc/php/conf.d 】【 /usr/local/etc/php-fpm.conf 】【 /usr/local/etc/php-fpm.d/www.conf 】

# php配置文件替换修改 
# RUN if [ -f /usr/local/etc/php-fpm.conf ]; then rm /usr/local/etc/php-fpm.conf; fi
COPY config/php-fpm.conf /usr/local/etc/
COPY config/php.ini /usr/local/etc/php/
COPY config/www.conf /usr/local/etc/php-fpm.d/
COPY config/opcache-recommended.ini /usr/local/etc/php/conf.d/

# 安装必要的PHP扩展PHP extensions，参考主机安装
RUN apt-get update && apt-get install -y apt-utils wget git mariadb-client \ 
       libpng-dev libjpeg-dev libpq-dev libfreetype6-dev libmcrypt-dev libicu-dev zlib1g-dev libmemcached-dev libjpeg62-turbo-dev libzip-dev \
       && pecl install mcrypt-1.0.2 \
       && docker-php-ext-enable mcrypt \
       && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-png-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
       && docker-php-ext-install gd opcache pdo_mysql mysqli zip bcmath exif sockets calendar intl \
       && rm -rf /var/lib/apt/lists/*
	
# 安装 php7 redis 扩展
ADD https://github.com/phpredis/phpredis/archive/3.1.4.tar.gz /tmp/phpredis.tar.gz
RUN mkdir -p /usr/src/php/ext/redis \
      && tar xf /tmp/phpredis.tar.gz -C /usr/src/php/ext/redis --strip-components=1 \
      && docker-php-ext-install redis \
      && rm -rd /usr/src/php/ext/redis \
      && rm /tmp/phpredis.tar.gz
         
# 设置drupal8版本以及安装根目录，需要经常更新
ENV DRUPAL_ROOT /var/www/drupal8
ENV DRUPAL_PRIVATE /var/www/private
ENV DRUPAL_VERSION 8.7.8

# 创建容器内部drupal8站点根目录和drupal8源代码下载目录
RUN set -x \
       && mkdir -p ${DRUPAL_ROOT} \
       && mkdir -p ${DRUPAL_PRIVATE} \
       && mkdir -p /usr/src/drupal8

# 安装 composer，国外网址难于下载，但是在github自动编译没有问题
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# 全局安装 drush Launcher（区别在每个drupal项目通过composer单独安装的 drush依赖本身）
RUN wget -O drush.phar https://github.com/drush-ops/drush-launcher/releases/download/0.6.0/drush.phar \
       && chmod +x drush.phar \
       && mv drush.phar /usr/local/bin/drush
              
# 全局安装 Drupal Console Launcher（区别在每个drupal项目单独安装的 Drupal Console本身）
RUN curl https://drupalconsole.com/installer -o /usr/local/bin/drupal \
       && chmod +x /usr/local/bin/drupal     

# 下载指定的 drupal8 版本
WORKDIR /usr/src/drupal8     
RUN curl -fSL "https://ftp.drupal.org/files/projects/drupal-${DRUPAL_VERSION}.tar.gz" -o drupal.tar.gz \
	&& chown -R www-data:www-data ${DRUPAL_ROOT}

WORKDIR ${DRUPAL_ROOT}

# USER root
# 容器启动时执行容器入口文件
COPY drupalphp-cmd.sh /usr/local/bin/
RUN  chmod +x /usr/local/bin/drupalphp-cmd.sh
CMD ["/usr/local/bin/drupalphp-cmd.sh"]
	