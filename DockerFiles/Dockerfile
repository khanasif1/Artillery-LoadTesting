# FROM node:8-alpine
FROM mcr.microsoft.com/powershell:6.2.1-alpine-3.8

WORKDIR /app

RUN apk add --update nodejs nodejs-npm
SHELL [ "pwsh", "--Command" ]

COPY ./package.json /app

# Restore the NPM packages
RUN ["npm", "install"]

# RUN pwsh -c Install-Module -Name Az -AllowClobber -Force

# COPY ./artifacts/ .
COPY ./aci_script/ .

# Build time argument
ARG ARTILLERY_ENVIRONMENT='local-dev'
ARG RESULTS_FILE_SHARE=.
ARG REPORT_NAME=report
ARG ARTILLERYIO_FILE=./load.yml 

# Run time argument, default to the build time argument
ENV ARTILLERY_ENVIRONMENT='local-dev'
ENV RESULTS_FILE_SHARE=$RESULTS_FILE_SHARE
ENV REPORT_NAME=$REPORT_NAME
ENV ARTILLERYIO_FILE=$ARTILLERYIO_FILE
ENV AZ_STORAGE_ACCOUNT=''
ENV AZ_STORAGE_KEY=''
ENV LOAD_TEST_NAME=''

ENTRYPOINT [ "pwsh", "run-load-test.ps1" ]
