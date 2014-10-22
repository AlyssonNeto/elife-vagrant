drush:
  git.latest:
    - name: https://github.com/drush-ops/drush.git
    - target: /opt/drush
    - require:
      - pkg: system
