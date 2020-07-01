#!/bin/bash

set -e

cd ${DRUPAL_ROOT}

# 判断站点是否已安装或者站点私有目录中是否存在升级提示文件 drupal.update
if [ ! -f ${DRUPAL_ROOT}/sites/default/settings.php ] || [ -f /var/www/private/drupal.update]; then

  # 下载指定网址的 drupal8或drupal9最新版本在drupal站点根目录【全新安装或者覆盖升级】
  curl -fSL ${DRUPAL_SRC} -o drupal.tar.gz
  
  if [ -f drupal.tar.gz ]; then
    tar -xz --strip-components=1 -f drupal.tar.gz
    rm drupal.tar.gz
  
    # 在drupal根目录安装 drupal console 本身
    #composer require drupal/console:~1.0 --prefer-dist --optimize-autoloader
    
  else
    echo "下载drupal源码安装包出现问题, 尝试重新运行 docker-compose up -d 命令"
  fi
   
else	
  	# 只进行drupalphp容器环境单纯重启的功能
    echo "站点私有目录中升级提示文件 drupal.update 不存在，将只进行php容器环境重启！"
fi

chown -R www-data:www-data ${DRUPAL_ROOT}
chown -R www-data:www-data ${DRUPAL_PRIVATE}

exec php-fpm
