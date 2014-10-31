php-packages:
    pkg.installed:
        - pkgs:
            - php5
            - php5-dev
            - php-pear
            - php5-mysql
            - php5-xsl
            - php5-gd
            - php5-curl
            - php5-mcrypt
            - php5-xdebug
            - libpcre3-dev # pcre for php5
        - require:
            - pkg: system

php-ini:
    file.managed:
        - name: /etc/php5/apache2/php.ini
        - backup: minion
        - source: salt://system/etc-php5-apache2-php.ini
        - require:
            - pkg: php-packages

a2enmod php5:
    cmd.run:
        - watch_in:
            - service: apache2

enable-php-mods:
    cmd.run:
        - name: php5enmod curl xsl gd mysql mcrypt
        - require:
            - pkg: php-packages
        - watch_in:
            - service: apache2

xdebug-config:
    file.managed:
        - name: /etc/php5/mods-available/xdebug.ini
        - source: salt://system/etc-php5-mods-available-xdebug.ini
        - template: jinja
        - require:
            - cmd: enable-php-mods

# EXTENSIONS

console-table:
    cmd.run:
        - name: "pear install Console_Table"
        - unless:
            - pear list| grep Console_Table
        - require:
            - pkg: php-packages

uploadprogress:
    cmd.run:
        - name: "pecl install uploadprogress"
        - unless:
            - pecl list | grep uploadprogress
        - require:
            - pkg: php-packages
