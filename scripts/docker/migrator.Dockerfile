FROM dimitri/pgloader

RUN pgloader --help

RUN apt-get update && apt-get -y install procps

ENV TERM=xterm
ENTRYPOINT ["watch", "-d", "ls ."] 