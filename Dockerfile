FROM ubuntu:24.04
WORKDIR /usr/local/app

COPY numbas_install.sh ./numbas_install.sh
RUN chmod +x ./numbas_install.sh

COPY startup.sh ./startup.sh
RUN chmod +x ./startup.sh

RUN ./numbas_install.sh

CMD ["bash", "-c", "./startup.sh"]