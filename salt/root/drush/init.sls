drush:
  git.latest:
    - name: https://github.com/drush-ops/drush.git
    - target: /usr/share/drush
    - rev: 6.x
    - require:
      - pkg: system
      
executable-on-path:
  file.symlink:
    - name: /usr/bin/drush
    - target: /usr/share/drush/drush
    - require:
      - git: drush
