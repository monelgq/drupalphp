#!/bin/bash

set -e

if [ -f /usr/src/drupal8/drupal.tar.gz ]; then
  mv /usr/src/drupal8/drupal.tar.gz ${DRUPAL_ROOT}
  cd ${DRUPAL_ROOT}
  tar -xz --strip-components=1 -f drupal.tar.gz
  rm drupal.tar.gz

# 在drupal根目录安装 drupalconsole本身      
  composer require drupal/console:~1.0 --prefer-dist --optimize-autoloader --sort-packages
    
  chown -R www-data:www-data ${DRUPAL_ROOT}
  chown -R www-data:www-data ${DRUPAL_PRIVATE}
    
fi

exec php-fpm