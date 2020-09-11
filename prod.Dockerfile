FROM google/dart:latest

WORKDIR /usr/src/app
COPY . .
RUN pub get

EXPOSE 3000

CMD [ "dart", "bin/main.dart" ]