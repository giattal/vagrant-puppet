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

  class { 'prometheus':
    manage_prometheus_server => true,
    version                  => '2.0.0',
    alerts                   => {
      'groups' => [
        {
          'name'  => 'alert.rules',
          'rules' => [
            {
              'alert'       => 'InstanceDown',
              'expr'        => 'up == 0',
              'for'         => '5m',
              'labels'      => {'severity' => 'page'},
              'annotations' => {
                'summary'     => 'Instance {{ $labels.instance }} down',
                'description' => '{{ $labels.instance }} of job {{ $labels.job }} has been down for more than 5 minutes.'
              },
            },
          ],
        },
      ],
    },
    scrape_configs           => [
      {
        'job_name'        => 'prometheus',
        'scrape_interval' => '10s',
        'scrape_timeout'  => '10s',
        'static_configs'  => [
          {
            'targets' => ['localhost:9090'],
            'labels'  => {'alias' => 'Prometheus'}
          }
        ],
      },
      {
        'job_name'        => 'node',
        'scrape_interval' => '5s',
        'scrape_timeout'  => '5s',
        'static_configs'  => [
          {
            'targets' => ['192.168.10.11:9100'],
            'labels'  => {'alias' => 'web1'}
          },
        ],
      },
    ],
    alertmanagers_config     => [
      {
        'static_configs' => [{'targets' => ['localhost:9093']}],
      },
    ],
  }

  class { 'prometheus::alertmanager':
    version   => '0.13.0',
    route     => {
      'group_by'        => ['alertname', 'cluster', 'service'],
      'group_wait'      => '30s',
      'group_interval'  => '5m',
      'repeat_interval' => '3h',
      'receiver'        => 'slack',
    },
    receivers => [
      {
        'name'          => 'slack',
        'slack_configs' => [
          {
            'api_url'       => 'https://hooks.slack.com/services/ABCDEFG123456',
            'channel'       => '#channel',
            'send_resolved' => true,
            'username'      => 'username'
          },
        ],
      },
    ],
  }
}
