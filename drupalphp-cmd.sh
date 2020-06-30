#!/bin/bash

set -e

cd ${DRUPAL_ROOT}

if [ ! -f ${DRUPAL_ROOT}/sites/default/settings.php ]; then

  # 下载指定网址的 drupal8或drupal9最新版本进行【全新安装】
  curl -fSL ${DRUPAL_SRC} -o drupal.tar.gz \
  && chown -R www-data:www-data ${DRUPAL_ROOT}
	
  if [ -f drupal.tar.gz ]; then
    tar -xz --strip-components=1 -f drupal.tar.gz
    rm drupal.tar.gz
  
    # 在drupal根目录安装 drupal console 本身
    composer require drupal/console:~1.0 --prefer-dist --optimize-autoloader
    
  else
    echo "下载drupal源码安装包出现问题, 尝试重新运行 docker-compose up -d 命令"
  fi
   
else 
	
  if [ -f /var/www/private/drupal-update.tar.gz ]; then  	
  	# 复制私有目录中的drupal升级文件进行【升级安装】，升级后要执行数据库更新操作
    mv /var/www/private/drupal-update.tar.gz ${DRUPAL_ROOT}
    tar -xz --strip-components=1 -f drupal-update.tar.gz
    rm drupal-update.tar.gz

    # 在drupal根目录安装 drupal console 本身
    composer require drupal/console:~1.0 --prefer-dist --optimize-autoloader
           
  else
  	# 只进行drupalphp容器环境单纯重启的功能
    echo "私有目录中drupal升级文件 drupal-update.tar.gz 不存在，将只进行php容器环境重启！"
  fi
    
fi

chown -R www-data:www-data ${DRUPAL_ROOT}
chown -R www-data:www-data ${DRUPAL_PRIVATE}

exec php-fpm
