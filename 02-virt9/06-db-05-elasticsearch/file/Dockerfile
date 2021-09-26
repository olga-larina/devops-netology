FROM centos:7

RUN yum install wget -y && \
    wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.15.0-linux-x86_64.tar.gz && \
    wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.15.0-linux-x86_64.tar.gz.sha512 && \
    yum install perl-Digest-SHA -y && \
    shasum -a 512 -c elasticsearch-7.15.0-linux-x86_64.tar.gz.sha512 && \
    tar -xzf elasticsearch-7.15.0-linux-x86_64.tar.gz && \
    groupadd elasticsearch && useradd -g elasticsearch elasticsearch && \
    mkdir /var/lib/logs && \
    chown -R elasticsearch:elasticsearch /var/lib/logs && \
    mkdir /var/lib/data && \
    chown -R elasticsearch:elasticsearch /var/lib/data && \
    chown -R elasticsearch:elasticsearch /elasticsearch-7.15.0/

EXPOSE 9200

USER elasticsearch

CMD ["sh", "-c", "/elasticsearch-7.15.0/bin/elasticsearch"]
