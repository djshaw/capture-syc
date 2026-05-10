# capture-syc

## Building

```shell
docker build . --tag capture-syc
```

## Running

```shell
./run-docker.sh
```

## Image Retention

Use `prune-old-images.sh` to keep the newest N distinct image days based on
filename day (`YYYY-MM-DD-HH.jpg`), even when some calendar days are missing.

Example:

```shell
./prune-old-images.sh ./output 7
```

## Docker Container

### Environment Variables

| Environment Variable | Domain            | Default   | Notes |
| -                    | -                 | -         | -     |
| `OUTPUT`             | Path to directory | `/output` | Location to put the downloaded file |
