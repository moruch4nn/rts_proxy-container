FROM eclipse-temurin:17-jre-jammy
LABEL authors="moruch4nn"

VOLUME /data
EXPOSE 25577
WORKDIR /data

ADD https://github.com/moruch4nn/VelocityConfigurationBuilder/releases/latest/download/vcb.jar /tmp/vcb.jar
RUN apt update -y && apt install -y jq curl
COPY setup-velocity.sh /tmp/setup-velocity.sh
ENTRYPOINT bash /tmp/setup-velocity.sh