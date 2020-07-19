class nginx (
  $package_name = 'nginx',
  $service_name = 'nginx',
  $doc_root = '/var/www/html'
) {
  package { $package_name:
    ensure => present,
  }
  service { $service_name:
    ensure => running,
    enable => true,
  }
  file { "$doc_root/index.html":
    source => "puppet:///modules/nginx/index.html",
  }
}
