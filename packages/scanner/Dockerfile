FROM public.ecr.aws/lambda/nodejs:16 as lambda

ARG PORT=8000
ENV PORT=$PORT

RUN yum install -y amazon-linux-extras && \
    amazon-linux-extras install epel -y

RUN amazon-linux-extras install -y epel && \
    yum update -y && \
    yum clean all

RUN yum install -y zip locate clamav clamav-freshclam

RUN cp /etc/freshclam.conf /etc/freshclam.conf.bak && \
  sed -i '/^Example/d' /etc/freshclam.conf

RUN freshclam -v

RUN corepack enable

WORKDIR ${LAMBDA_TASK_ROOT}/src
COPY . .
RUN yarn && yarn build && mv build ${LAMBDA_TASK_ROOT}
RUN yarn install --production=true --modules-folder ${LAMBDA_TASK_ROOT}/build/node_modules
COPY Dockerfile /tmp/Dockerfile
WORKDIR ${LAMBDA_TASK_ROOT}/build
RUN rm -rf ${LAMBDA_TASK_ROOT}/src

CMD [ "build/index.handler" ]