FROM php:7.4.12-apache

#
# APACHE2
#
ENV APACHE_DOCUMENT_ROOT=/var/www/html/public

# Create web root
RUN mkdir $APACHE_DOCUMENT_ROOT && touch $APACHE_DOCUMENT_ROOT/index.php
RUN chown -R www-data:www-data $APACHE_DOCUMENT_ROOT

# Change default document root to /public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Create config file for ServerName in apache2
RUN printf '#\n# The ServerName directive sets the request scheme, hostname and port that the server uses to identify itself.\n# http://httpd.apache.org/docs/2.4/mod/core.html#servername\n#\n' > $APACHE_CONFDIR/conf-available/server-name.conf
RUN printf 'ServerName localhost' >> $APACHE_CONFDIR/conf-available/server-name.conf

# Enable server-name.conf
RUN a2enconf server-name.conf

# Enable mod_rewrite
RUN a2enmod rewrite

#
# PHP
#

# Copy default production config to be the default/base config.
RUN cp $PHP_INI_DIR/php.ini-production $PHP_INI_DIR/php.ini

RUN apt update && apt install libzip-dev -y && apt clean

RUN docker-php-ext-install pdo pdo_mysql zip

#
# Composer
#

RUN apt update && apt install wget -y && apt clean

COPY ./install-composer.sh /root/install-composer.sh
RUN /root/install-composer.sh