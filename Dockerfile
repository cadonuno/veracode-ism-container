FROM ubuntu:20.04

#Install dependencies
ARG DEBIAN_FRONTEND=noninteractive
RUN apt update
RUN apt upgrade -y
RUN cat /etc/apt/sources.list
RUN apt install -y openjdk-21-jre-headless unzip --fix-missing

#Unpack Veracode ISM files
COPY ./Veracode_ISM_Installer_Linux.zip /usr/src/myapp/Veracode_ISM_Installer_Linux.zip
RUN unzip /usr/src/myapp/Veracode_ISM_Installer_Linux.zip -d /usr/src/myapp/ism
RUN unzip /usr/src/myapp/ism/program_files/veracode_ism.zip -d /usr/src/myapp/ism
RUN cp /usr/src/myapp/ism/program_files/info.properties /usr/src/myapp/ism/veracode_ism/config/info.properties

#Copy entry point script to handle Token & API keys
COPY ./startup.sh /startup.sh

ENTRYPOINT ["/startup.sh"]
