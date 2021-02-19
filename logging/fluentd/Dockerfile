FROM fluent/fluentd:v1.12-1
USER root
RUN apk add --no-cache --update --virtual .build-deps \
        sudo build-base ruby-dev \
 && gem install fluent-plugin-elasticsearch --no-document --version 5.0.0 \
 && gem install fluent-plugin-grok-parser --no-document --version 2.6.2 \
 && sudo gem sources --clear-all \
 && apk del .build-deps \
 && rm -rf /tmp/* /var/tmp/* /usr/lib/ruby/gems/*/cache/*.gem

COPY fluent.conf /fluentd/etc
USER fluent
