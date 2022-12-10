FROM rust:latest as base

RUN apt-get update -y && apt-get upgrade -y && apt-get autoremove -y

FROM base as builder-base

RUN apt-get install -y curl protobuf-compiler wget

RUN rustup default nightly && \
    rustup target add wasm32-unknown-unknown wasm32-wasi --toolchain nightly

FROM builder-base as environment

RUN curl -sL https://deb.nodesource.com/setup_18.x | bash -
RUN apt-get update && apt-get install -y nodejs yarn


RUN curl https://rustwasm.github.io/wasm-pack/installer/init.sh -sSf | sh && \
    npm install -g wasm-pack wrangler@latest

FROM environment as builder

ENV CF_API_TOKEN=""

ADD . /app
WORKDIR /app

COPY . .
RUN wrangler

FROM builder as dev

EXPOSE 6284
EXPOSE 8787
EXPOSE 8976
EXPOSE 9229

ENTRYPOINT [ "wrangler" ]
CMD [ "dev" ]
