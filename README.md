# Vagrant-Puppet Test LAB
Automation with Puppet + Vagrant

* 3 VMs
* 2 webservers running nginx + node exporter.
* 1 balancer server that runs Haproxy + Prometheus + Alert Manager + node exporter.


```sh
                                   VM2 (Web server)
                                     +---------+
                         +-------->  |  Nginx  |
VM1 (LB and Prometheus)  |           +---------+
    +------------+       |
    |  HAProxy   +-------+
    +------------+       |         VM3 (Web server)
                         |           +---------+
                         +-------->  |  Nginx  |
                                     +---------+
```

### Pre :

| App | version |
| ------ | ------ |
| Vagrant | 2.2.9 |

### Installed in process:

| App | version |
| ------ | ------ |
| Puppet | 6.12.0 |
| Facter | 3.14.7 |

### Usage:
```sh
$ vagrant up
```

* ports for local host browser
* prometheus port = 9090
* haproxy stats port = 8888 user:pass puppet:puppet
