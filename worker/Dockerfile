FROM ruby:3.0.2-alpine3.13 AS base

ENV BUNDLER_VERSION=2.2.25

RUN mkdir -p /opt/pinger
WORKDIR /opt/pinger
ENV LANG=C.UTF-8 \
  BUNDLE_PATH=/bundle \
  BUNDLE_APP_CONFIG=/bundle \
  BUNDLE_BIN=/bundle/bin \
  GEM_HOME=/bundle
ENV PATH "opt/pinger/bin:${BUNDLE_BIN}:${PATH}"

RUN gem install bundler -v 2.2.25

RUN apk add --update --no-cache \
  tini \
  tzdata

FROM base AS dependencies

RUN apk --update add --virtual .build-dependencies \
  autoconf \
  automake \
  build-base \
  curl \
  git \
  gmp-dev \
  libc6-compat \
  libc-dev \
  libcurl \
  libressl-dev \
  libssl1.1 \
  libstdc++ \
  libtool \
  libxml2-dev \
  libxslt-dev \
  linux-headers \
  nodejs \
  openssh-client \
  openssl-dev \
  postgresql-dev \
  readline-dev \
  ruby-dev

COPY Gemfile*  /opt/pinger/

FROM dependencies AS main_gems

RUN bundle install -j 4 --frozen --without development test \
  && find /bundle/ -name "*.gem" -delete \
  && find /bundle/ -name "*.c" -delete \
  && find /bundle/ -name "*.o" -delete

FROM main_gems AS dev_gems

RUN bundle install -j 4 --frozen --with development test \
  && find /bundle/ -name "*.gem" -delete \
  && find /bundle/ -name "*.c" -delete \
  && find /bundle/ -name "*.o" -delete

FROM dev_gems AS development

COPY . /opt/pinger

FROM development AS artefacts

RUN rm -rf .git/

FROM base AS release

COPY --from=artefacts /opt/pinger/ /opt/pinger/
COPY --from=main_gems /bundle/ /bundle/

ENTRYPOINT ["/sbin/tini", "--"]
