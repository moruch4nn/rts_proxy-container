FROM eclipse-temurin:17-jre-jammy
LABEL authors="moruch4nn"

RUN apt update -y
WORKDIR /tmp
RUN apt install -y jq curl
COPY setup-velocity.sh /tmp/setup-velocity.sh
RUN ./setup-velocity.sh
COPY start-velocity.sh /tmp/start-velocity.sh
WORKDIR data
CMD /tmp/start-velocity.sh