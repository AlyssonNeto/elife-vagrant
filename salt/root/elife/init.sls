
# FILES

{% if not salt['file.directory_exists']('/opt/public/drupal-webroot') %}
drupal-webroot:
  git.latest:
    - name: git@github.com:elifesciences/drupal-webroot.git
    - target: /opt/public/drupal-webroot
    - rev: 7.x-1.x-stable
    - require:
      - pkg: system

  file.directory:
    - name: /opt/public/drupal-webroot
    - user: www-data
    - group: www-data
    - dir_mode: 775
    - file_mode: 664
    - recurse:
      - user
      - group
      - mode
    - require:
      - git: drupal-webroot
      - pkg: system # apache and it's user must exist

modules-link:
  file.symlink:
    - name: /opt/public/drupal-webroot/sites/default/modules
    - target: /shared/elife_module/modules
    - user: www-data
    - group: www-data
    - require:
      - file: drupal-webroot

themes-link:
  file.symlink:
    - name: /opt/public/drupal-webroot/sites/default/themes
    - target: /shared/elife_module/themes
    - user: www-data
    - group: www-data
    - require:
      - file: drupal-webroot

settings-link:
  file.symlink:
    - name: /opt/public/drupal-webroot/sites/default/settings.php
    - target: /opt/public/settings.php
    - user: www-data
    - group: www-data
    - require:
      - file: drupal-webroot

{% endif %}


{% if not salt['file.directory_exists']('/opt/public/drupal-highwire') %}
drupal-highwire:
  git.latest:
    - name: git@github.com:elifesciences/drupal-highwire.git
    - target: /opt/public/drupal-highwire
    - rev: 7.x-1.x-stable
    - require:
      - pkg: system

  file.directory:
    - name: /opt/public/drupal-highwire
    - user: www-data
    - group: www-data
    - dir_mode: 775 # www-data user has less privileges than the group-owner.
    - file_mode: 664
    - recurse:
      - user
      - group
      - mode
    - require:
      - git: drupal-highwire
      - pkg: system # apache and it's user must exist

{% endif %}

elife-files:
  file.directory:
    - name: /opt/public/drupal-webroot/sites/default/files
    - file_mode: 777 # write but not execute

# VHOST

/etc/apache2/sites-available/elife.vhost.conf:
  file.managed:
    - source: salt://elife/apache.vhost.conf
    - watch_in:
      - service: apache2
    - require:
      - pkg: system

/etc/apache2/sites-enabled/elife.vhost.conf:
  file.symlink:
    - target: /etc/apache2/sites-available/elife.vhost.conf
    - watch_in:
      - service: apache2
    - require:
      - pkg: system

# DATABASE

elife-db:
  mysql_database.present:
    - name: jnl_elife

load-mysql-db:
    cmd.run:
        - name: mysql -u admin -padmin jnl_elife < /opt/public/jnl-elife.sql && touch /root/journal-loaded.lock
        - creates: 
          - /root/journal-loaded.lock
        - require:
            - mysql_user: mysql-root-user
            - mysql_grants: mysql-root-user
            - mysql_database: elife-db

# DRUSH COMMANDS

disable-cdn:
    cmd.run:
        - name: /usr/bin/drush -l 'elife.vbox.local' -r '/opt/public/drupal-webroot' --yes pm-disable cdn
        - require: 
            - cmd: load-mysql-db

