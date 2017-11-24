#!/bin/bash

set -e

if [ ! -f ${DRUPAL_ROOT}/sites/default/settings.php ]; then

  if [ -f /usr/src/drupal8/drupal.tar.gz ]; then
    mv /usr/src/drupal8/drupal.tar.gz ${DRUPAL_ROOT}
    cd ${DRUPAL_ROOT}
    tar -xz --strip-components=1 -f drupal.tar.gz
    rm drupal.tar.gz
        
    # 在drupal根目录安装 drupalconsole本身      
    composer require drupal/console:~1.0 --prefer-dist --optimize-autoloader --sort-packages
       
  else
    echo "下载drupal安装包出现问题, 尝试重新运行 docker-compose up -d 命令"  
  fi
    
else 
  echo "drupal 8 已经安装, 如需升级请使用drush"
fi
    
chown -R www-data:www-data ${DRUPAL_ROOT}
chown -R www-data:www-data ${DRUPAL_PRIVATE}
    
exec php-fpm
