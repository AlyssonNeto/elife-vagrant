# gets a basic system configured for us to use
# if an application requires heavier customisation, 
# feel free to break it out into its own module

system:
    pkg.installed:
        - pkgs:
            - curl
            - git
            - python-pip
            - mysql-client
            - mysql-server
            - apache2
            - zip # also provides 'unzip'
            - openvpn
            - python-mysqldb
            - phpmyadmin # not configured
            - memcached
            - elinks
            - vim

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


# WEBSERVER

apache2:
    file.managed:
        - name: /etc/apache2/apache2.conf
        - source: salt://system/etc-apache2-apache2.conf
        - require:
            - pkg: system

    service:
        - running
        - require: 
            - pkg: system

a2enmod rewrite expires:
    cmd.run:
        - watch_in:
            - service: apache2

a2dissite 000-default:
    cmd.run:
        - watch_in:
            - service: apache2

# DATABASE

mysql:
    file.managed:
        - name: /etc/mysql/my.cnf
        - source: salt://system/etc-mysql-my.cnf
        - require:
            - pkg: system

    service.running:
        - require:
            - pkg: system
        - watch:
            - file: mysql

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

# MEMCACHED

memcached-config:
    file.managed:
        - name: /etc/memcached.conf
        - source: salt://system/etc-memcached.conf
        - require:
            - pkg: system

# OPENVPN

openvpn:
    file.managed:
        - name: /etc/openvpn/client.conf
        - source: salt://system/etc-openvpn-client.conf
        - require:
            - pkg: system
        
    service.running:
        - watch:
            - file: openvpn

            
vpn-files:
    file.recurse:
        - name: /etc/openvpn/
        - source: salt://system/openvpn-credentials/
        - watch_in:
            - service: openvpn
