# centos-systemd-puppetmaster-consul
Container running CentOS, systemd, Puppet master and Consul

[![](https://images.microbadger.com/badges/image/pdouble16/centos-systemd-puppetmaster-consul.svg)](http://microbadger.com/images/pdouble16/centos-systemd-puppetmaster-consul "Get your own image badge on microbadger.com") [![](https://images.microbadger.com/badges/version/pdouble16/centos-systemd-puppetmaster-consul.svg)](http://microbadger.com/images/pdouble16/centos-systemd-puppetmaster-consul "Get your own version badge on microbadger.com") [![](https://images.microbadger.com/badges/commit/pdouble16/centos-systemd-puppetmaster-consul.svg)](http://microbadger.com/images/pdouble16/centos-systemd-puppetmaster-consul "Get your own commit badge on microbadger.com") [![](https://images.microbadger.com/badges/license/pdouble16/centos-systemd-puppetmaster-consul.svg)](http://microbadger.com/images/pdouble16/centos-systemd-puppetmaster-consul "Get your own license badge on microbadger.com")

Bits taken from:
* https://github.com/CentOS/CentOS-Dockerfiles/tree/master/systemd/centos7
* https://github.com/puppetlabs/puppet-in-docker/blob/master/puppetserver-standalone
* https://github.com/puppetlabs/puppet-in-docker/blob/master/puppet-agent-centos
* https://github.com/hashicorp/docker-consul

## Usage

This image must be run from a host running systemd itself to establish the 'systemd' cgroup, unless you want to configure that group yourself.

In the background:
```
docker run -d --privileged -v /sys/fs/cgroup:/sys/fs/cgroup:ro pdouble16/centos-systemd-puppetmaster-consul
```

In the foreground:
```
docker run -it --rm --privileged -v /sys/fs/cgroup:/sys/fs/cgroup:ro pdouble16/centos-systemd-puppetmaster-consul
```

To create a docker image with additional services:
```Dockerfile
FROM pdouble16/centos-systemd-puppetmaster-consul

RUN yum -y install httpd; yum clean all; systemctl enable httpd.service
EXPOSE 80

```

