# Redis Geo Cache

This is an example Redis configuration that runs a primary Redis in one region and replicas in other regions. Writes to the primary region propagate, writes to other regions are region local.

Redis includes a `replica-read-only no` setting that makes it especially effective for geo caching. When you run replicas that allow writes, you can write to the closest replica for most ephemeral cache data, and write to the master for commands that should propagate.

### Usage

This is a Fly app that requires volumes. Assuming you want a primary redis in the `scl` region and a replica in the `ord` region, this is what you need to do.

1. Clone this repository
2. `fly launch`, choose to import the existing config
3. Choose `n` when it asks if you want to deploy
4. Set a redis password: `fly secrets set REDIS_PASSWORD=<password>`
5. Create a volume in your primary region:
   ```
   fly volumes create redis_server --size 10 --region scl
   ```
6. `fly deploy`
7. Add volumes in other regions:
   ```
   fly volumes create redis_server --size 10 --region ord
   ```
8. Add instances: `fly scale count 2`

### Connecting from your application

You should run your application in the same regions as Redis, and use the region specific addresses to connect. It's helpful to set a matching `PRIMARY_REGION` environment variable on any application you connect to your Redis cluster so you can make choices about where to send writes.

The primary Redis URL is:

```bash
# format
redis://x:<password>@<primary-region>.<appname>.internal:5432

# example in scl
redis://x:password@scl.my-redis-app.internal:5432
```

Read replicas are similar, but using a different region prefix (the `$FLY_REGION` environment variable is handy here).

To generate a local read replica with Node.js, you might do something like:

```javascript
const primary = new URL("redis://x:password@scl.my-redis-app.internal:5432")
const replica = new URL(primary)
replica.hostname = `${process.env['FLY_REGION']}.my-redis-app.internal`
replica.toString()
// 'redis://x:password@ord.my-redis-app.internal:5432'
```