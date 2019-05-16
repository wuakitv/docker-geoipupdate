FROM golang:alpine as build

ENV VERSION=4.0.2
VOLUME /geodata
RUN apk add --update wget git bash
RUN wget -P /tmp/build/ https://github.com/maxmind/geoipupdate/archive/v${VERSION}.tar.gz
RUN tar -C /tmp/build/ -zxvf /tmp/build/v${VERSION}.tar.gz

WORKDIR /tmp/build/geoipupdate-${VERSION}

ENV GOPATH /tmp/build/geoipupdate-${VERSION}
WORKDIR /tmp/build/geoipupdate-${VERSION}/cmd/geoipupdate
RUN go get -t ./... 2> /dev/null; exit 0
RUN go build

RUN cp /tmp/build/geoipupdate-${VERSION}/cmd/geoipupdate/geoipupdate /usr/bin/

FROM alpine

RUN apk add -q --update bash

COPY --from=build /usr/bin/geoipupdate /usr/bin/
COPY update.sh /usr/bin/
ENTRYPOINT ["update.sh"]
