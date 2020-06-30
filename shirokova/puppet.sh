#!/bin/bash

sudo apt-get update && sudo apt-get install ruby -y
sudo gem install --no-document puppet

puppet module install puppet-nginx --version 0.6.0

cat > /opt/nginx.pp << EOF
include ::nginx

selboolean { 'httpd_setrlimit':
  value      => 'on',
  persistent => true,
}
file { ['/var/www','/var/www/webapp'] :
  ensure  => 'directory',
  owner   => 'nginx',
  group   => 'nginx',
  mode    => '0755',
  require => Class['nginx'],
}
  
file { '/var/www/webapp/index.html':
  ensure  => present,
  content => '<html><head><title>tf-puppet-nginx</title></head><body><h1>hello world</h1></body></html>',
  owner   => 'nginx',
  group   => 'nginx',
  mode    => '0644',
  require => File['/var/www/webapp'],
}
nginx::resource::server { 'webapp':
  listen_port    => 80,
  listen_options => 'default_server',
  server_name    => ['_'],
  www_root       => '/var/www/webapp',
  require        => Selboolean['httpd_setrlimit'],
  notify         => Service['nginx'],
}
EOF

puppet apply /opt/nginx.pp
