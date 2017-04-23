#!/bin/bash

set -e

if [ -f /usr/src/drupal8/drupal.tar.gz ]; then
    mv /usr/src/drupal8/drupal.tar.gz ${DRUPAL_ROOT}
    cd ${DRUPAL_ROOT}
    tar -xz --strip-components=1 -f drupal.tar.gz
    rm drupal.tar.gz
    
#    composer require drupal/console:~1.0 --prefer-dist --optimize-autoloader
#    composer update drupal/console --with-dependencies
    
    chown -R www-data:www-data ${DRUPAL_ROOT}
fi

exec php-fpm