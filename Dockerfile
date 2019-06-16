FROM alpine:3.7

LABEL Name="MySQL Database transfer"
LABEL Version="1.0"
LABEL maintainer="Diogo Munhoz Fraga <digmunhoz@gmail.com>"

RUN apk add -U \
    mysql \
    tzdata \
    mysql-client \
    bash \
    py-pip \
    && pip install \
        awscli

RUN ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime

USER root
CMD [ "/opt/MySQL-BackupandRestore.sh" ]