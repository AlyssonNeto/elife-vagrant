# 
# builds php 5.3 and updates paths to binaries
#

php-build-dependencies:
    pkg.installed:
        - pkgs:
            - libicu-dev
            - libxml2 # not sure if this is necessary of not, but it replaces xml2-config
#            - xml2-config # doesnt exist
            - libxml2-dev 
            - libbz2-dev 
            - libpng12-dev
            - libxpm-dev 
            - libxpm4 
            - libcurl4-openssl-dev 
            - libdb4o-cil-dev
            - libfreetype6-dev 
            - libgd2-xpm-dev 
            - libsasl2-dev 
            - libmhash-dev 
            - libxslt1-dev 
            - libmcrypt-dev
            - libt1-dev
            - libgmp-dev
            - libgd2-xpm-dev
            - libfreetype6-dev
            - libreadline-dev
            - libgd-dev
            - libenchant-dev
            - libgmp-dev
            - libgmp3-dev
            
install-phpbrew:
    cmd.run:
        - cwd: /usr/bin/
        - name: |
            wget -O phpbrew https://github.com/phpbrew/phpbrew/raw/master/phpbrew
            chmod +x phpbrew
        - creates: /usr/bin/phpbrew

init-phpbrew:
    cmd.run:
        - name: |
            phpbrew init 
            echo 'source /root/.phpbrew/bashrc' >> /root/.bashrc
            ln -s /usr/include/freetype2 /usr/include/freetype2/freetype
            touch /root/.init-phpbrew.lock
        - creates: /root/.init-phpbrew.lock
        - require:
            - cmd: install-phpbrew
            - pkg: php-build-dependencies

compile-php-5.3:
    cmd.run: 
        - name: phpbrew install 5.3.29 +bcmath +bz2 +calendar +cgi +cli +ctype +dom +exif +fileinfo +filter +fpm +ftp +gd +gettext +hash +iconv +icu +intl +ipc +ipv6 +json +mbregex +mbstring +mcrypt +mhash +mysql +openssl +pcntl +pcre +pdo +phar +posix +readline +session +soap +sockets +sqlite +tokenizer +xml_all +xmlrpc +zip +zlib
        - creates: /root/.phpbrew/php/php-5.3.29/bin/php
        - require:
            - cmd: init-phpbrew

post-5.3-install:
    cmd.run:
        - name: |
            update-alternatives --install /usr/bin/pecl          pecl /root/.phpbrew/php/php-5.3.29/bin/pecl       60
            update-alternatives --install /usr/bin/pear          pear /root/.phpbrew/php/php-5.3.29/bin/pear       60
            update-alternatives --install /usr/bin/php           php /root/.phpbrew/php/php-5.3.29/bin/php        60
            update-alternatives --install /usr/bin/phpize        phpize /root/.phpbrew/php/php-5.3.29/bin/phpize     60
            update-alternatives --install /usr/bin/php-config    php-config /root/.phpbrew/php/php-5.3.29/bin/php-config 60
            update-alternatives --install /usr/bin/php5-cgi      php5-cgi /root/.phpbrew/php/php-5.3.29/bin/php-cgi    60
            chmod a+rX /root/ /root/.phpbrew /root/.phpbrew/php /root/.phpbrew/php/php-5.3.29 
            chmod a+rx /root/.phpbrew/php/php-5.3.29/bin/* 
        - requires:
            - cmd: compile-php-5.3

