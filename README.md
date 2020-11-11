# Redis Geo Cache

This is an example Redis configuration that runs _replicas_ against an existing Redis master server. Redis has a very simple replication model – it is subscription based so the master doesn't need any extra configuration.

Redis also includes a `replica-read-only no` setting that makes it especially effective for geo caching. When you run replicas that allow writes, you can write to the closest replica for most ephemeral cache data, and write to the master for commands that should propagate.

### Usage

This is a Fly app that requires volumes. The general setup process is:

1. `flyctl init`: choose `6379` for port
2. `flyctl volumes create redis_server --region <region> --size 10`
    > Create one volume per region you want to run in, name them all `redis_server`
3. Update `fly.toml` with the master address
4. `flyctl secrets set REDIS_PASSWORD="<password>" REDIS_MASTER_PASSWORD="<master-password>"`
    > These can be the same if you want your app to authenticate against both master and the replicas with the same password
5. `flyctl deploy`
6. `flyctl scale set min=3 max=3`
    > Scale to the number of volumes you created.

### TLS Notes
This example is configured to use TLS. You can disable TLS by commenting out all the lines under `#tls settings` in `redis.conf`. If you want to use the TLS configuration, you will need to generate certificates:

1. Create `certs` directory for the Docker image:
  
    `mkdir -p certs`
2. Generate server certificates:

   `mkcert -key-file certs/redis-server.key -cert-file certs/redis-server.crt redis-example.fly.dev`
3. Generate a client certificate:

    `mkcert --client -key-file redis-client.key -cert-file redis-client.crt redis-example.fly.dev`
4. Copy the root CA certificate:

    `cp "$(mkcert -CAROOT)/rootCA.pem" certs/rootCA.crt`

When you're done you should see a directory layout like this:

* `/certs`
    * `/redis-server.crt`
    * `/redis-server.key`
    * `/rootCA.crt`
* `/redis-client.crt`
* `/redis-client.key`

This configures Redis to listen on port 7379, which means updating the internal port in `fly.toml`:

```toml
[[services]]
internal_port = 7379
...
```