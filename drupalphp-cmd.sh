#!/bin/bash

set -e

cd ${DRUPAL_ROOT}

# 如果不存在index.php入口文件，进行全新安装
if [ ! -f ${DRUPAL_ROOT}/index.php ]; then

  # 下载指定网址的 drupal8 或者 drupal9 最新版本进行全新安装
  curl -fSL ${DRUPAL_SRC} -o drupal.tar.gz
	
  if [ -f drupal.tar.gz ]; then
    tar -xz --strip-components=1 -f drupal.tar.gz
    rm drupal.tar.gz
      
    # 在drupal根目录安装 drupal console 本身（暂时不支持drupal9，所以在容器当中手动安装）      
    # composer require drupal/console:~1.0 --prefer-dist --optimize-autoloader
    
  else
    echo "下载drupal源码包出现问题, 尝试重新运行 docker-compose up -d 命令"  
  fi
     
fi

# 如果存在drupal设置文件并且私有目录中存在升级提示文件 drupal.update，进行升级安装
if [ -f ${DRUPAL_ROOT}/sites/default/settings.php ] && [ -f /var/www/private/drupal.update ]; then

  # 删除drupal站点根目录下的core和vendor两个目录
  rm -rf ${DRUPAL_ROOT}/core ${DRUPAL_ROOT}/vendor
  
  # 下载指定网址的 drupal8 或者 drupal9 最新版本源代码并解压覆盖到站点根目录
  curl -fSL ${DRUPAL_SRC} -o drupal.tar.gz
	
  if [ -f drupal.tar.gz ]; then
    tar -xz --strip-components=1 -f drupal.tar.gz
    rm drupal.tar.gz
    
    # drupal升级源代码解压后默认删除升级提示文件 drupal.update，每次升级需要临时创建该文件
    rm /var/www/private/drupal.update
    
  else
    echo "下载drupal8安装包出现问题, 尝试重新运行 docker-compose up -d 命令"  
  fi

fi

# 修改根目录和私有目录权限为网站运行权限
chown -R www-data:www-data ${DRUPAL_ROOT}
chown -R www-data:www-data ${DRUPAL_PRIVATE}

exec php-fpm
