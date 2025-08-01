---
sidebar_position: 90
---

# Environment Variables

:::caution

To change environment variables, you must recreate the Immich containers.
Just restarting the containers does not replace the environment within the container!

In order to recreate the container using docker compose, run `docker compose up -d`.
In most cases docker will recognize that the `.env` file has changed and recreate the affected containers.
If this does not work, try running `docker compose up -d --force-recreate`.

:::

## Docker Compose

| Variable           | Description                     |  Default  | Containers               |
| :----------------- | :------------------------------ | :-------: | :----------------------- |
| `IMMICH_VERSION`   | Image tags                      | `release` | server, machine learning |
| `UPLOAD_LOCATION`  | Host path for uploads           |           | server                   |
| `DB_DATA_LOCATION` | Host path for Postgres database |           | database                 |

:::tip
These environment variables are used by the `docker-compose.yml` file and do **NOT** affect the containers directly.
:::

## General

| Variable                            | Description                                                                               |           Default            | Containers               | Workers            |
| :---------------------------------- | :---------------------------------------------------------------------------------------- | :--------------------------: | :----------------------- | :----------------- |
| `TZ`                                | Timezone                                                                                  |        <sup>\*1</sup>        | server                   | microservices      |
| `IMMICH_ENV`                        | Environment (production, development)                                                     |         `production`         | server, machine learning | api, microservices |
| `IMMICH_LOG_LEVEL`                  | Log level (verbose, debug, log, warn, error)                                              |            `log`             | server, machine learning | api, microservices |
| `IMMICH_MEDIA_LOCATION`             | Media location inside the container ⚠️**You probably shouldn't set this**<sup>\*2</sup>⚠️ |           `/data`            | server                   | api, microservices |
| `IMMICH_CONFIG_FILE`                | Path to config file                                                                       |                              | server                   | api, microservices |
| `NO_COLOR`                          | Set to `true` to disable color-coded log output                                           |           `false`            | server, machine learning |                    |
| `CPU_CORES`                         | Number of cores available to the Immich server                                            | auto-detected CPU core count | server                   |                    |
| `IMMICH_API_METRICS_PORT`           | Port for the OTEL metrics                                                                 |            `8081`            | server                   | api                |
| `IMMICH_MICROSERVICES_METRICS_PORT` | Port for the OTEL metrics                                                                 |            `8082`            | server                   | microservices      |
| `IMMICH_PROCESS_INVALID_IMAGES`     | When `true`, generate thumbnails for invalid images                                       |                              | server                   | microservices      |
| `IMMICH_TRUSTED_PROXIES`            | List of comma-separated IPs set as trusted proxies                                        |                              | server                   | api                |
| `IMMICH_IGNORE_MOUNT_CHECK_ERRORS`  | See [System Integrity](/docs/administration/system-integrity)                             |                              | server                   | api, microservices |

\*1: `TZ` should be set to a `TZ identifier` from [this list][tz-list]. For example, `TZ="Etc/UTC"`.
`TZ` is used by `exiftool` as a fallback in case the timezone cannot be determined from the image metadata. It is also used for logfile timestamps and cron job execution.

\*2: This path is where the Immich code looks for the files, which is internal to the docker container. Setting it to a path on your host will certainly break things, you should use the `UPLOAD_LOCATION` variable instead.

## Workers

| Variable                 | Description                                                                                          | Default | Containers |
| :----------------------- | :--------------------------------------------------------------------------------------------------- | :-----: | :--------- |
| `IMMICH_WORKERS_INCLUDE` | Only run these workers.                                                                              |         | server     |
| `IMMICH_WORKERS_EXCLUDE` | Do not run these workers. Matches against default workers, or `IMMICH_WORKERS_INCLUDE` if specified. |         | server     |

:::info
Information on the current workers can be found [here](/docs/administration/jobs-workers).
:::

## Ports

| Variable      | Description    |                  Default                   |
| :------------ | :------------- | :----------------------------------------: |
| `IMMICH_HOST` | Listening host |                 `0.0.0.0`                  |
| `IMMICH_PORT` | Listening port | `2283` (server), `3003` (machine learning) |

## Database

| Variable                            | Description                                                                            |  Default   | Containers                     |
| :---------------------------------- | :------------------------------------------------------------------------------------- | :--------: | :----------------------------- |
| `DB_URL`                            | Database URL                                                                           |            | server                         |
| `DB_HOSTNAME`                       | Database host                                                                          | `database` | server                         |
| `DB_PORT`                           | Database port                                                                          |   `5432`   | server                         |
| `DB_USERNAME`                       | Database user                                                                          | `postgres` | server, database<sup>\*1</sup> |
| `DB_PASSWORD`                       | Database password                                                                      | `postgres` | server, database<sup>\*1</sup> |
| `DB_DATABASE_NAME`                  | Database name                                                                          |  `immich`  | server, database<sup>\*1</sup> |
| `DB_SSL_MODE`                       | Database SSL mode                                                                      |            | server                         |
| `DB_VECTOR_EXTENSION`<sup>\*2</sup> | Database vector extension (one of [`vectorchord`, `pgvector`, `pgvecto.rs`])           |            | server                         |
| `DB_SKIP_MIGRATIONS`                | Whether to skip running migrations on startup (one of [`true`, `false`])               |  `false`   | server                         |
| `DB_STORAGE_TYPE`                   | Optimize concurrent IO on SSDs or sequential IO on HDDs ([`SSD`, `HDD`])<sup>\*3</sup> |   `SSD`    | server                         |

\*1: The values of `DB_USERNAME`, `DB_PASSWORD`, and `DB_DATABASE_NAME` are passed to the Postgres container as the variables `POSTGRES_USER`, `POSTGRES_PASSWORD`, and `POSTGRES_DB` in `docker-compose.yml`.

\*2: If not provided, the appropriate extension to use is auto-detected at startup by introspecting the database. When multiple extensions are installed, the order of preference is VectorChord, pgvecto.rs, pgvector.

\*3: Uses either [`postgresql.ssd.conf`](https://github.com/immich-app/base-images/blob/main/postgres/postgresql.ssd.conf) or [`postgresql.hdd.conf`](https://github.com/immich-app/base-images/blob/main/postgres/postgresql.hdd.conf) which mainly controls the Postgres `effective_io_concurrency` setting to allow for concurrenct IO on SSDs and sequential IO on HDDs.

:::info

All `DB_` variables must be provided to all Immich workers, including `api` and `microservices`.

`DB_URL` must be in the format `postgresql://immichdbusername:immichdbpassword@postgreshost:postgresport/immichdatabasename`.
You can require SSL by adding `?sslmode=require` to the end of the `DB_URL` string, or require SSL and skip certificate verification by adding `?sslmode=require&sslmode=no-verify`.

When `DB_URL` is defined, the `DB_HOSTNAME`, `DB_PORT`, `DB_USERNAME`, `DB_PASSWORD` and `DB_DATABASE_NAME` database variables are ignored.

:::

## Redis

| Variable         | Description    | Default | Containers |
| :--------------- | :------------- | :-----: | :--------- |
| `REDIS_URL`      | Redis URL      |         | server     |
| `REDIS_SOCKET`   | Redis socket   |         | server     |
| `REDIS_HOSTNAME` | Redis host     | `redis` | server     |
| `REDIS_PORT`     | Redis port     | `6379`  | server     |
| `REDIS_USERNAME` | Redis username |         | server     |
| `REDIS_PASSWORD` | Redis password |         | server     |
| `REDIS_DBINDEX`  | Redis DB index |   `0`   | server     |

:::info
All `REDIS_` variables must be provided to all Immich workers, including `api` and `microservices`.

`REDIS_URL` must start with `ioredis://` and then include a `base64` encoded JSON string for the configuration.
More information can be found in the upstream [ioredis] documentation.

When `REDIS_URL` or `REDIS_SOCKET` are defined, the `REDIS_HOSTNAME`, `REDIS_PORT`, `REDIS_USERNAME`, `REDIS_PASSWORD`, and `REDIS_DBINDEX` variables are ignored.
:::

Redis (Sentinel) URL example JSON before encoding:

<details>
<summary>JSON</summary>

```json
{
  "sentinels": [
    {
      "host": "redis-sentinel-node-0",
      "port": 26379
    },
    {
      "host": "redis-sentinel-node-1",
      "port": 26379
    },
    {
      "host": "redis-sentinel-node-2",
      "port": 26379
    }
  ],
  "name": "redis-sentinel"
}
```

</details>

## Machine Learning

| Variable                                                    | Description                                                                                         |             Default             | Containers       |
| :---------------------------------------------------------- | :-------------------------------------------------------------------------------------------------- | :-----------------------------: | :--------------- |
| `MACHINE_LEARNING_MODEL_TTL`                                | Inactivity time (s) before a model is unloaded (disabled if \<= 0)                                  |              `300`              | machine learning |
| `MACHINE_LEARNING_MODEL_TTL_POLL_S`                         | Interval (s) between checks for the model TTL (disabled if \<= 0)                                   |              `10`               | machine learning |
| `MACHINE_LEARNING_CACHE_FOLDER`                             | Directory where models are downloaded                                                               |            `/cache`             | machine learning |
| `MACHINE_LEARNING_REQUEST_THREADS`<sup>\*1</sup>            | Thread count of the request thread pool (disabled if \<= 0)                                         |       number of CPU cores       | machine learning |
| `MACHINE_LEARNING_MODEL_INTER_OP_THREADS`                   | Number of parallel model operations                                                                 |               `1`               | machine learning |
| `MACHINE_LEARNING_MODEL_INTRA_OP_THREADS`                   | Number of threads for each model operation                                                          |               `2`               | machine learning |
| `MACHINE_LEARNING_WORKERS`<sup>\*2</sup>                    | Number of worker processes to spawn                                                                 |               `1`               | machine learning |
| `MACHINE_LEARNING_HTTP_KEEPALIVE_TIMEOUT_S`<sup>\*3</sup>   | HTTP Keep-alive time in seconds                                                                     |               `2`               | machine learning |
| `MACHINE_LEARNING_WORKER_TIMEOUT`                           | Maximum time (s) of unresponsiveness before a worker is killed                                      | `120` (`300` if using OpenVINO) | machine learning |
| `MACHINE_LEARNING_PRELOAD__CLIP__TEXTUAL`                   | Comma-separated list of (textual) CLIP model(s) to preload and cache                                |                                 | machine learning |
| `MACHINE_LEARNING_PRELOAD__CLIP__VISUAL`                    | Comma-separated list of (visual) CLIP model(s) to preload and cache                                 |                                 | machine learning |
| `MACHINE_LEARNING_PRELOAD__FACIAL_RECOGNITION__RECOGNITION` | Comma-separated list of (recognition) facial recognition model(s) to preload and cache              |                                 | machine learning |
| `MACHINE_LEARNING_PRELOAD__FACIAL_RECOGNITION__DETECTION`   | Comma-separated list of (detection) facial recognition model(s) to preload and cache                |                                 | machine learning |
| `MACHINE_LEARNING_ANN`                                      | Enable ARM-NN hardware acceleration if supported                                                    |             `True`              | machine learning |
| `MACHINE_LEARNING_ANN_FP16_TURBO`                           | Execute operations in FP16 precision: increasing speed, reducing precision (applies only to ARM-NN) |             `False`             | machine learning |
| `MACHINE_LEARNING_ANN_TUNING_LEVEL`                         | ARM-NN GPU tuning level (1: rapid, 2: normal, 3: exhaustive)                                        |               `2`               | machine learning |
| `MACHINE_LEARNING_DEVICE_IDS`<sup>\*4</sup>                 | Device IDs to use in multi-GPU environments                                                         |               `0`               | machine learning |
| `MACHINE_LEARNING_MAX_BATCH_SIZE__FACIAL_RECOGNITION`       | Set the maximum number of faces that will be processed at once by the facial recognition model      |  None (`1` if using OpenVINO)   | machine learning |
| `MACHINE_LEARNING_PING_TIMEOUT`                             | How long (ms) to wait for a PING response when checking if an ML server is available                |             `2000`              | server           |
| `MACHINE_LEARNING_AVAILABILITY_BACKOFF_TIME`                | How long to ignore ML servers that are offline before trying again                                  |             `30000`             | server           |
| `MACHINE_LEARNING_RKNN`                                     | Enable RKNN hardware acceleration if supported                                                      |             `True`              | machine learning |
| `MACHINE_LEARNING_RKNN_THREADS`                             | How many threads of RKNN runtime should be spinned up while inferencing.                            |               `1`               | machine learning |

\*1: It is recommended to begin with this parameter when changing the concurrency levels of the machine learning service and then tune the other ones.

\*2: Since each process duplicates models in memory, changing this is not recommended unless you have abundant memory to go around.

\*3: For scenarios like HPA in K8S. https://github.com/immich-app/immich/discussions/12064

\*4: Using multiple GPUs requires `MACHINE_LEARNING_WORKERS` to be set greater than 1. A single device is assigned to each worker in round-robin priority.

:::info

While the `textual` model is the only one required for smart search, some users may experience slow first searches
due to backups triggering loading of the other models into memory, which blocks other requests until completed.
To avoid this, you can preload the other models (`visual`, `recognition`, and `detection`) if you have enough RAM to do so.

Additional machine learning parameters can be tuned from the admin UI.

:::

## Prometheus

| Variable                   | Description                                                                                                           | Default | Containers | Workers            |
| :------------------------- | :-------------------------------------------------------------------------------------------------------------------- | :-----: | :--------- | :----------------- |
| `IMMICH_TELEMETRY_INCLUDE` | Collect these telemetries. List of `host`, `api`, `io`, `repo`, `job`. Note: You can also specify `all` to enable all |         | server     | api, microservices |
| `IMMICH_TELEMETRY_EXCLUDE` | Do not collect these telemetries. List of `host`, `api`, `io`, `repo`, `job`                                          |         | server     | api, microservices |

## Secrets

The following variables support reading from files, either via [Systemd Credentials][systemd-creds] or [Docker secrets][docker-secrets] for additional security.

To use any of these, either set `CREDENTIALS_DIRECTORY` to a directory that contains files whose name is the “regular variable” name, and whose content is the secret. If using Docker Secrets, setting `CREDENTIALS_DIRECTORY=/run/secrets` will cause all secrets present to be used. Alternatively, replace the regular variable with the equivalent `_FILE` environment variable as below. The value of the `_FILE` variable should be set to the path of a file containing the variable value.

| Regular Variable   | Equivalent Docker Secrets '\_FILE' Variable |
| :----------------- | :------------------------------------------ |
| `DB_HOSTNAME`      | `DB_HOSTNAME_FILE`<sup>\*1</sup>            |
| `DB_DATABASE_NAME` | `DB_DATABASE_NAME_FILE`<sup>\*1</sup>       |
| `DB_USERNAME`      | `DB_USERNAME_FILE`<sup>\*1</sup>            |
| `DB_PASSWORD`      | `DB_PASSWORD_FILE`<sup>\*1</sup>            |
| `DB_URL`           | `DB_URL_FILE`<sup>\*1</sup>                 |
| `REDIS_PASSWORD`   | `REDIS_PASSWORD_FILE`<sup>\*2</sup>         |

\*1: See the [official documentation][docker-secrets-docs] for
details on how to use Docker Secrets in the Postgres image.

\*2: See [this comment][docker-secrets-example] for an example of how
to use a Docker secret for the password in the Redis container.

[tz-list]: https://en.wikipedia.org/wiki/List_of_tz_database_time_zones#List
[docker-secrets-example]: https://github.com/docker-library/redis/issues/46#issuecomment-335326234
[docker-secrets-docs]: https://github.com/docker-library/docs/tree/master/postgres#docker-secrets
[docker-secrets]: https://docs.docker.com/engine/swarm/secrets/
[ioredis]: https://ioredis.readthedocs.io/en/latest/README/#connect-to-redis
[systemd-creds]: https://systemd.io/CREDENTIALS/
