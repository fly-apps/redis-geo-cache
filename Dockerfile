FROM redis:alpine

RUN apk update && apk add bind-tools

ADD redis.conf /usr/local/etc/redis/redis.conf
ADD start-redis-server.sh /usr/bin/
RUN chmod +x /usr/bin/start-redis-server.sh

CMD ["start-redis-server.sh"]