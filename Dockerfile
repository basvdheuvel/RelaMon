# syntax=docker/dockerfile:1

FROM openjdk:17

WORKDIR /app

COPY ./install-node.sh /app/
RUN chmod +x /app/install-node.sh

COPY ["package.json", "package-lock.json*", "/app/"]

RUN ./install-node.sh

COPY ["*.js", "/app/"]
ADD implementations/CSA /app/implementations/CSA
ADD implementations/Weather /app/implementations/Weather

COPY ./run.sh /app/
RUN chmod +x /app/run.sh

COPY ["RelaMon.jar", "rascal-shell-stable.jar", "/app/"]
COPY ./transpiler.sh /app/
RUN chmod +x /app/transpiler.sh
