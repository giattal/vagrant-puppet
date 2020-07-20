node 'web-a', 'web-b' {
  include nginx
} 

node 'balancer' {

  include ::haproxy

  haproxy::listen { 'web':
    collect_exported => false,
    ipaddress        => '0.0.0.0',
    ports            => '80',
    mode             => 'http',
    options          => {
      'option'  => ['httplog'],
      'balance' => 'roundrobin',
    }
  }

  haproxy::balancermember { 'web-a':
    listening_service => 'web',
    server_names      => 'web-a',
    ipaddresses       => '192.168.10.111',
    ports             => '80',
    options           => 'check',
  }

  haproxy::balancermember { 'web-b':
    listening_service => 'web',
    server_names      => 'web-b',
    ipaddresses       => '192.168.10.112',
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
            'targets' => ['192.168.10.111:9100'],
            'labels'  => {'alias' => 'web-a'}
          },
          {
            'targets' => ['192.168.10.112:9100'],
            'labels'  => {'alias' => 'web-b'}
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
