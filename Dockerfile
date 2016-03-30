FROM srdc/java:oraclejdk-8

### explicitly set user/group IDs
RUN groupadd -r cassandra --gid=999 && useradd -r -g cassandra --uid=999 cassandra

### grab gosu for easy step-down from root
ENV GOSU_VERSION 1.7
RUN set -x \
	&& apt-get update && apt-get install -y --no-install-recommends ca-certificates wget && rm -rf /var/lib/apt/lists/* \
	&& wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" \
	&& wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc" \
	&& export GNUPGHOME="$(mktemp -d)" \
	&& gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
	&& gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
	&& rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
	&& chmod +x /usr/local/bin/gosu \
	&& gosu nobody true \
	&& apt-get purge -y --auto-remove ca-certificates

RUN apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys 514A2AD631A57A16DD0047EC749D6EEC0353B12C

### install cassandra

#add cassandra source
RUN echo 'deb http://www.apache.org/dist/cassandra/debian 33x main' | tee -a /etc/apt/sources.list.d/cassandra.sources.list

#add public keys to avoid package signature warnings during package updates, 
#we need to add three public keys from the  Apache Software Foundation associated 
#with the package repositories.
RUN gpg --keyserver pgp.mit.edu --recv-keys F758CE318D77295D
RUN gpg --export --armor F758CE318D77295D | apt-key add -

RUN gpg --keyserver pgp.mit.edu --recv-keys 2B5C1B00
RUN gpg --export --armor 2B5C1B00 | apt-key add -

RUN gpg --keyserver pgp.mit.edu --recv-keys 0353B12C
RUN gpg --export --armor 0353B12C | apt-key add -

#install cassandra
ENV CASSANDRA_VERSION 3.3

RUN apt-get update 
RUN apt-get install -y cassandra
RUN rm -rf /var/lib/apt/lists/*

ENV CASSANDRA_CONFIG /etc/cassandra

COPY cassandra-entrypoint.sh /cassandra-entrypoint.sh
ENTRYPOINT ["/cassandra-entrypoint.sh"]

RUN mkdir -p /var/lib/cassandra "$CASSANDRA_CONFIG" \
	&& chown -R cassandra:cassandra /var/lib/cassandra "$CASSANDRA_CONFIG" \
	&& chmod 777 /var/lib/cassandra "$CASSANDRA_CONFIG"
VOLUME /var/lib/cassandra

# 7000: intra-node communication
# 7001: TLS intra-node communication
# 7199: JMX
# 9042: CQL
# 9160: thrift service
EXPOSE 7000 7001 7199 9042 9160
CMD ["cassandra", "-f"]