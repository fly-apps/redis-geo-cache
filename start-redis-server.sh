#!/bin/sh
sysctl vm.overcommit_memory=1
sysctl net.core.somaxconn=1024

# write region to local redis
nohup /bin/sh -c "sleep 10 && redis-cli -a $REDIS_PASSWORD set fly_region $FLY_REGION" >> /dev/null 2>&1 &

# start the server
redis-server /usr/local/etc/redis/redis.conf \
    --requirepass $REDIS_PASSWORD \
    --replicaof $REDIS_MASTER \
    --masterauth $REDIS_MASTER_AUTH