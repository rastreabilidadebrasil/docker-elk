FROM java:7-jdk
MAINTAINER William Durand <william.durand1@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

# Elasticsearch
RUN \
    wget -qO - http://packages.elasticsearch.org/GPG-KEY-elasticsearch | apt-key add - && \
    if ! grep "elasticsearch" /etc/apt/sources.list; then echo "deb http://packages.elasticsearch.org/elasticsearch/1.1/debian stable main" >> /etc/apt/sources.list;fi && \
    if ! grep "logstash" /etc/apt/sources.list; then echo "deb http://packages.elasticsearch.org/logstash/1.5/debian stable main" >> /etc/apt/sources.list;fi && \
    apt-get update

RUN \
    apt-get install -y elasticsearch=1.1.1 && \
    apt-get clean && \
    sed -i '/#cluster.name:.*/a cluster.name: logstash' /etc/elasticsearch/elasticsearch.yml && \
    sed -i '/#path.data: \/path\/to\/data/a path.data: /data' /etc/elasticsearch/elasticsearch.yml

# Logstash
RUN apt-get install -y supervisor curl wget logstash && \
    apt-get clean && \
    /opt/logstash/bin/plugin install logstash-input-log4j2

# Kibana
RUN \
    apt-get install -y nginx && \
  if ! grep "daemon off" /etc/nginx/nginx.conf; then sed -i '/worker_processes.*/a daemon off;' /etc/nginx/nginx.conf;fi && \
  mkdir -p /var/www && \
  wget -O kibana.tar.gz https://download.elasticsearch.org/kibana/kibana/kibana-3.1.0.tar.gz && \
    tar xzf kibana.tar.gz -C /opt && \
    ln -s /opt/kibana-3.1.0 /var/www/kibana && \
    sed -i 's/"http:\/\/"+window.location.hostname+":9200"/"http:\/\/"+window.location.hostname+":"+window.location.port/' /opt/kibana-3.1.0/config.js

# configure supervisor jobs
ADD etc/supervisor/conf.d/elasticsearch.conf /etc/supervisor/conf.d/elasticsearch.conf
ADD etc/logstash/logstash.conf /etc/logstash/logstash.conf
ADD etc/supervisor/conf.d/logstash.conf /etc/supervisor/conf.d/logstash.conf
ADD etc/supervisor/conf.d/nginx.conf /etc/supervisor/conf.d/nginx.conf
ADD etc/nginx/default /etc/nginx/sites-enabled/default

EXPOSE 80 28778 28777 9200

CMD [ "/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf" ]
