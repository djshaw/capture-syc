# capture-syc

## Building

```shell
docker build . --tag capture-syc
```

## Running

```shell
./run-docker.sh
```

## Docker Container

### Environment Variables

| Environment Variable | Domain            | Default   | Notes |
| -                    | -                 | -         | -     |
| `OUTPUT`             | Path to directory | `/output` | Location to put the downloaded file |

## TODO List

[ ] remove syc.py.  It can be replaced with the right `wget -O $(TZ=America/Toronto date %Y-%m-%d-%h).jpg ...`