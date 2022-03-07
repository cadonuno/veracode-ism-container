FROM ubuntu:20.04

#Install dependencies
ARG DEBIAN_FRONTEND=noninteractive
RUN sed -i -e 's/http:\/\/archive/mirror:\/\/mirrors/' -e 's/http:\/\/security/mirror:\/\/mirrors/' -e 's/\/ubuntu\//\/mirrors.txt/' /etc/apt/sources.list
RUN apt update
RUN cat /etc/apt/sources.list
RUN apt install -y openjdk-8-jre-headless unzip --fix-missing

#Unpack Veracode ISM files
COPY ./veracode-ism-22_1_10.zip /usr/src/myapp/veracode-ism-22_1_10.zip
RUN unzip /usr/src/myapp/veracode-ism-22_1_10.zip -d /usr/src/myapp/ism

#Copy entry point script to handle Token & API keys
COPY ./startup.sh /startup.sh

ENTRYPOINT ["/startup.sh"]
