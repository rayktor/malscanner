# syntax=docker/dockerfile:1
FROM public.ecr.aws/lambda/nodejs:16 as clamav

ARG PORT=8000
ENV PORT=$PORT

RUN yum update -y && \
    yum install -y amazon-linux-extras && \
    amazon-linux-extras install -y epel && \
    yum clean all

RUN yum install -y clamav clamav-freshclam

RUN sed -i '/^Example/d' /etc/freshclam.conf

RUN freshclam -v

FROM clamav

RUN corepack enable

WORKDIR ${LAMBDA_TASK_ROOT}/src

COPY . .

RUN yarn && yarn build && mv build ${LAMBDA_TASK_ROOT}

RUN yarn install --production=true --modules-folder ${LAMBDA_TASK_ROOT}/build/node_modules

WORKDIR ${LAMBDA_TASK_ROOT}/build

RUN rm -rf ${LAMBDA_TASK_ROOT}/src

CMD [ "build/index.handler" ]