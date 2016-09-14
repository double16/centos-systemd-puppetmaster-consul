FROM centos:7
MAINTAINER Patrick Double <pat@patdouble.com> (@double16)

ARG BUILD_DATE
ARG SOURCE_COMMIT
ARG DOCKERFILE_PATH
ARG SOURCE_TYPE

ENV container=docker PUPPETDB_TERMINUS_VERSION="4.2.0" PUPPET_SERVER_VERSION="2.6.0" CONSUL_VERSION="0.6.4" PUPPETSERVER_JAVA_ARGS="-Xms256m -Xmx256m" PATH=/opt/puppetlabs/server/bin:/opt/puppetlabs/puppet/bin:/opt/puppetlabs/bin:$PATH

LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.docker.dockerfile="$DOCKERFILE_PATH/Dockerfile" \
      org.label-schema.license="Apache-2.0" \
      org.label-schema.name="Base for testing with CentOS 7 + systemd + puppet master $PUPPET_SERVER_VERSION + consul $CONSUL_VERSION" \
      org.label-schema.url="https://github.com/double16/centos-systemd-puppetmaster-consul" \
      org.label-schema.vcs-ref=$SOURCE_COMMIT \
      org.label-schema.vcs-type="$SOURCE_TYPE" \
      org.label-schema.vcs-url="https://github.com/double16/centos-systemd-puppetmaster-consul.git"

# Create a consul user and group first so the IDs get set the same way, even as
# the rest of this may change over time.
RUN groupadd consul && \
    useradd -r -g consul consul

RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
    rm -f /lib/systemd/system/multi-user.target.wants/*;\
    rm -f /etc/systemd/system/*.wants/*;\
    rm -f /lib/systemd/system/local-fs.target.wants/*; \
    rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
    rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
    rm -f /lib/systemd/system/basic.target.wants/*;\
    rm -f /lib/systemd/system/anaconda.target.wants/*; \
    rpm -Uvh https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm && \
    yum upgrade -y && \
    yum update -y && \
    yum install -y wget unzip which && \
    yum install -y puppetserver-"$PUPPET_SERVER_VERSION" puppetdb-termini-"$PUPPETDB_TERMINUS_VERSION" && \
    yum clean all && \
    gpg --keyserver pool.sks-keyservers.net --recv-keys 91A6E7F85D05C65630BEF18951852D87348FFC4C B42F6819007F00F88E364FD4036A9C25BF357DD4 && \
    mkdir -p /tmp/build && \
    cd /tmp/build && \
    wget https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip && \
    wget https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_SHA256SUMS && \
    wget https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_SHA256SUMS.sig && \
    gpg --batch --verify consul_${CONSUL_VERSION}_SHA256SUMS.sig consul_${CONSUL_VERSION}_SHA256SUMS && \
    grep consul_${CONSUL_VERSION}_linux_amd64.zip consul_${CONSUL_VERSION}_SHA256SUMS | sha256sum -c && \
    unzip -d /bin consul_${CONSUL_VERSION}_linux_amd64.zip && \
    curl -o /usr/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.9/gosu-amd64" && \
    curl -o /usr/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/1.9/gosu-amd64.asc" && \
    gpg --verify /usr/bin/gosu.asc && \
    rm /usr/bin/gosu.asc && \
    chmod +x /usr/bin/gosu && \
    cd /tmp && \
    rm -rf /tmp/build && \
    rm -rf /root/.gnupg

COPY puppetserver /etc/default/puppetserver
COPY puppetserver.init /etc/init.d/puppetserver
COPY logback.xml /etc/puppetlabs/puppetserver/
COPY request-logging.xml /etc/puppetlabs/puppetserver/
COPY puppetdb.conf /etc/puppetlabs/puppet/


# The /consul/data dir is used by Consul to store state. The agent will be started
# with /consul/config as the configuration directory so you can add additional
# config files in that location.
RUN mkdir -p /consul/data && \
    mkdir -p /consul/config && \
    chown -R consul:consul /consul
COPY consul.init /etc/init.d/consul

RUN puppet config set autosign true --section master && \
    puppet config set storeconfigs_backend puppetdb --section main && \
    puppet config set storeconfigs true --section main && \
    puppet config set reports puppetdb --section main && \
    chmod +x /etc/init.d/puppetserver /etc/init.d/consul && \
    systemctl enable puppetserver.service && \
    systemctl enable consul.service && \
    mkdir /var/run/dbus

EXPOSE 8140 8300 8301 8301/udp 8302 8302/udp 8400 8500 8600 8600/udp

VOLUME [ "/sys/fs/cgroup", "/etc/puppetlabs/code/", "/consul/data" ]

CMD ["/usr/sbin/init"]

