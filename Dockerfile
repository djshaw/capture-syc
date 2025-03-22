FROM library/openjdk:21-bookworm AS build

RUN apt update && apt install --assume-yes build-essential && mkdir /app
COPY Main.java Makefile sunrisesunsetlib.jar /app/
RUN cd app && make


FROM library/openjdk:21-bookworm AS result

RUN mkdir /app && mkdir /output
COPY --from=build /app/Main.class /app/sunrisesunsetlib.jar /app/
WORKDIR /app
ENTRYPOINT ["/app/run.sh"]
