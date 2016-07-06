#!/bin/bash

set -e


export NODE_MASTER=${NODE_MASTER:-true}
export NODE_DATA=${NODE_DATA:-true}
/elasticsearch_logging_discovery >> /usr/share/elasticsearch/config/elasticsearch.yml
export HTTP_PORT=${HTTP_PORT:-9200}
export TRANSPORT_PORT=${TRANSPORT_PORT:-9300}

# Add elasticsearch as command if needed
if [ "${1:0:1}" = '-' ]; then
  set -- elasticsearch "$@"
fi

# Drop root privileges if we are running elasticsearch
# allow the container to be started with `--user`
if [ "$1" = 'elasticsearch' -a "$(id -u)" = '0' ]; then
  # Change the ownership of /usr/share/elasticsearch/data to elasticsearch
  chown -R elasticsearch:elasticsearch /data

  set -- gosu elasticsearch "$@"
  #exec gosu elasticsearch "$BASH_SOURCE" "$@"
fi

# As argument is not related to elasticsearch,
# then assume that user wants to run his own process,
# for example a `bash` shell to explore this image
exec "$@"
