FROM ubuntu:24.04 AS result

ARG DEBIAN_FRONTEND=noninteractive

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    rm --force /etc/apt/apt.conf.d/docker-clean \
 && apt update \
 && apt install --yes --no-install-recommends ca-certificates curl jq \
 && mkdir /app \
 && mkdir /output

COPY run.sh /app/
WORKDIR /app
ENTRYPOINT ["/app/run.sh"]
