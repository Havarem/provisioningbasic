consul_prereq:
  pkg.installed:
    - pkgs:
      - curl
      - unzip

/usr/local/bin/consul:
  file.managed:
    - user: root
    - group: root
    - source: salt://consul/consul
    - mode: '0755'

/etc/consul.d:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 755

/etc/consul.d/config.json:
  file.managed:
    - source: salt://consul/consul.config
    - template: jinja
    - require:
      - file: /etc/consul.d
    - defaults:
      addr: {{ grains['ip4_interfaces']['enp0s8'][0] }}
      name: {{ grains['fqdn'] }}

/etc/default/consul:
  file.managed:
    - source: salt://consul/consul.default

/etc/systemd/system/consul.service:
  file.managed:
    - source: salt://consul/consul.service
    - require:
      - file: /usr/local/bin/consul
      - file: /etc/consul.d/config.json
      - file: /etc/default/consul

consul:
  service.running:
    - enable: True
    - reload: True
    - watch:
      - file: /etc/consul.d/config.json
      - file: /usr/local/bin/consul

python-pip:
  pkg.installed

python-consul:
  pip.installed:
    - require:
      - pkg: python-pip