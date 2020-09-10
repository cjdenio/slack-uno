# Download reflex
FROM golang:latest

ENV GOPATH /go

RUN go get github.com/cespare/reflex

# Dart stuff
FROM google/dart:latest

COPY --from=0 /go/bin/reflex /bin/reflex

WORKDIR /usr/src/app
COPY . .
RUN pub get

EXPOSE 3000

CMD [ "reflex", "-s", "--", "dart", "bin/main.dart" ]