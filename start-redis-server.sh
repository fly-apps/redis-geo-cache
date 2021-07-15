#!/bin/sh
sysctl vm.overcommit_memory=1
sysctl net.core.somaxconn=1024

# write region to local redis
nohup /bin/sh -c "sleep 10 && redis-cli -a $REDIS_PASSWORD set fly_region $FLY_REGION" >> /dev/null 2>&1 &

if [ "$PRIMARY_REGION" = "$FLY_REGION" ]; then
    # start master
    echo "Starting primary in $PFLY_REGION"
    redis-server /usr/local/etc/redis/redis.conf \
        --requirepass $REDIS_PASSWORD
else
    # start replica
    echo "Starting replica: $FLY_REGION <- $PRIMARY_REGION"

    # redis is dumb and can't replicate from an ipv6 only hostname
    ip=$(dig aaaa $PRIMARY_REGION.$FLY_APP_NAME.internal +short | head -n 1)

    echo "" >> /usr/local/etc/redis/redis.conf
    echo "replicaof $ip 6379" >> /usr/local/etc/redis/redis.conf
    redis-server /usr/local/etc/redis/redis.conf \
        --requirepass $REDIS_PASSWORD \
        --masterauth $REDIS_PASSWORD
fi