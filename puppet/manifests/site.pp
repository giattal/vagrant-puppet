node 'web1', 'web2' {
  class { 'nginx': }
} 

node 'balancer' {

  include ::haproxy

  haproxy::listen { 'web':
    collect_exported => false,
    ipaddress        => '0.0.0.0',
    ports            => '8080',
    mode             => 'http',
    options          => {
      'option'  => ['httplog'],
      'balance' => 'roundrobin',
    }
  }

  haproxy::balancermember { 'web1':
    listening_service => 'web',
    server_names      => 'web1',
    ipaddresses       => '192.168.10.11',
    ports             => '80',
    options           => 'check',
  }

  haproxy::balancermember { 'web2':
    listening_service => 'web',
    server_names      => 'web2',
    ipaddresses       => '192.168.10.12',
    ports             => '80',
    options           => 'check',
  }

  haproxy::listen { 'stats':
    ipaddress => '0.0.0.0',
    ports     => '8888',
    options   => {
      'mode'  => 'http',
      'stats' => [
        'uri /',
        'auth puppet:puppet'
      ],
    },
  }

}
