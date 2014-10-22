# gets a basic system configured for us to use
# if an application requires heavier customisation, 
# feel free to break it out into its own module

system:
    pkg.installed:
        - pkgs:
            - git
            - python-pip
            - php5
            - php5-mysql
            - mysql-client
            - mysql-server
            - apache2
            - zip # also provides 'unzip'
            - openvpn
            - python-mysqldb
#            - phpmyadmin
#            - memcached
    # any python requirements we want installed globally 
    # that are not available as a package
    pip.installed:
        - requirements: salt://system/requirements.txt
        - require:
            - pkg: system

# SSH known hosts

# the `ssh_known_hosts` is currently lacking global options.
# https://github.com/saltstack/salt/issues/6878
ssh-well-known-hosts:
  file.managed:
    - name: /etc/ssh/ssh_known_hosts
    - user: root
    - group: root
    - mode: 0644
    - contents: |
        # https://confluence.atlassian.com/display/BITBUCKET/What+are+the+Bitbucket+IP+addresses+I+should+use+to+configure+my+corporate+firewall
        bitbucket.org,131.103.20.167,131.103.20.168,131.103.20.169,131.103.20.170 ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAubiN81eDcafrgMeLzaFPsw2kNvEcqTKl/VqLat/MaB33pZy0y3rJZtnqwR2qOOvbwKZYKiEO1O6VqNEBxKvJJelCq0dTXWT5pbO2gDXC6h6QDXCaHo6pOHGPUy+YBaGQRGuSusMEASYiWunYN0vCAI8QaXnWMXNMdFP3jHAJH0eDsoiGnLPBlBp4TNm6rYI74nMzgz3B9IikW4WVK+dc8KZJZWYjAuORU3jc1c/NPskD2ASinf8v3xnfXeukU0sJ5N6m5E8VLjObPEO+mN2t/FZTMZLiFqPWc/ALSqnMnnhwrNi2rbfg/rd/IpL8Le3pSBne8+seeFVBoGqzHM9yXw==

        # https://help.github.com/articles/what-ip-addresses-does-github-use-that-i-should-whitelist
        github.com,gist.github.com,192.30.252.0/22 ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==

# PHP

php-ini:
    file.managed:
        - name: /etc/php5/apache2/php.ini
        - source: salt://system/php.ini
        - require:
            - pkg: system

# WEBSERVER

apache2:
    service:
        - running
        - require: 
            - pkg: system

/etc/apache2/mods-enabled/rewrite.load:
    file.symlink:
        - target: /etc/apache2/mods-available/rewrite.load
        - require:
            - pkg: system
        - watch_in:
            - service: apache2

# DATABASE

mysql:
    service:
        - running
        - require:
            - pkg: system

mysql-root-user:
    mysql_user.present:
        - name: admin
        - password: admin
        - require:
          - service: mysql
    mysql_grants.present:
        - user: admin
        - grant: all privileges
        - database: "*.*"
        - require:
          - service: mysql
# OPENVPN

openvpn:
    service:
        - running
        - require:
            - pkg: system
