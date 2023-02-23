FROM ubuntu:latest
LABEL authors="moruch4nn"

RUN apt update -y
RUN apt install -y jq

ENTRYPOINT ["top", "-b"]