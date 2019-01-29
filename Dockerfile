FROM alpine

LABEL Name="MySQL Database transfer"
LABEL Version="1.0"
LABEL maintainer="Diogo Munhoz Fraga <digmunhoz@gmail.com>"

RUN apk add -U mysql mysql-client bash

ADD src /opt/
RUN chmod -R 700 /opt/

USER root
CMD [ "/opt/MySQL-BackupandRestore.sh" ]