# capture-syc

## Building

```shell
docker build .
```

## Running

```shell
docker run --volume $( pwd )/output:/output:rw capture-syc
```

| Environment Variable | Domain            | Default   | Notes |
| -                    | -                 | -         | -     |
| `OUTPUT`             | Path to directory | `/output` | Location to put the downloaded file |
