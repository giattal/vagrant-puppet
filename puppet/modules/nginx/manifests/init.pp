class nginx {
  package { 'nginx':
    ensure => installed,
  }

  service { 'nginx':
    ensure  => true,
    enable  => true,
    require => Package['nginx'],
  }

  file { "/var/www/html/index.html":
    source => "puppet:///modules/nginx/index.html",
  }
}

