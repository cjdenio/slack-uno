FROM --platform=linux/amd64 dart:2.13

WORKDIR /usr/src/app

COPY . .

RUN pub get

EXPOSE 3000

CMD [ "dart", "bin/main.dart" ]
