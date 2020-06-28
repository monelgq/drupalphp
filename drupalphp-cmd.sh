#!/bin/bash

set -e

cd ${DRUPAL_ROOT}

if [ ! -f ${DRUPAL_ROOT}/sites/default/settings.php ]; then

  # 下载指定网址的 drupal8 最新版本进行全新安装
  curl -fSL "https://ftp.drupal.org/files/projects/drupal-8.8.8.tar.gz" -o drupal.tar.gz \
  && chown -R www-data:www-data ${DRUPAL_ROOT}
	
  if [ -f drupal.tar.gz ]; then
    tar -xz --strip-components=1 -f drupal.tar.gz
    rm drupal.tar.gz
  
    # 在drupal根目录安装 drupal console 本身      
    composer require drupal/console:~1.0 --prefer-dist --optimize-autoloader
    
  else
    echo "下载drupal8安装包出现问题, 尝试重新运行 docker-compose up -d 命令"  
  fi
   
else 
	
  # 复制drupal8最新版本进行升级安装
  if [ -f /var/www/private/d8.tar.gz ]; then
    mv /var/www/private/d8.tar.gz ${DRUPAL_ROOT}
    tar -xz --strip-components=1 -f d8.tar.gz
    rm d8.tar.gz
           
  else
    echo "私有目录中drupal升级文件 d8.tar.gz 不存在，将进行php容器环境重启！"  
  fi
    
fi

chown -R www-data:www-data ${DRUPAL_ROOT}
chown -R www-data:www-data ${DRUPAL_PRIVATE}

exec php-fpm
