FROM library/openjdk:21-bookworm AS build

RUN apt update && apt install --assume-yes build-essential && mkdir /app
COPY Main.java \
     Makefile \
     run.sh \
     sunrisesunsetlib.jar \
     syc.py /app/
RUN cd app && make


FROM library/openjdk:21-bookworm AS result

# TODO: set non-interactive
RUN apt update \
 && apt install --assume-yes python3 python3-pip \
 && mkdir /app \
 && mkdir /output

# TODO: use a venv
COPY requirements.txt /app/requirements.txt
RUN pip3 install --break-system-packages --requirement /app/requirements.txt

COPY --from=build /app/run.sh /app/syc.py /app/Main.class /app/sunrisesunsetlib.jar /app/
WORKDIR /app
ENTRYPOINT ["/app/run.sh"]
