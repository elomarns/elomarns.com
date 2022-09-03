FROM ruby:3.1.2-alpine3.16

LABEL maintainer="elomarns@elomarns.com"

ARG BUNDLER_VERSION=2.3.21
ARG WEBSITE_PATH=/elomarns.com
ARG JEKYLL_PORT=4000

ENV BUNDLER_VERSION=${BUNDLER_VERSION}
ENV WEBSITE_PATH=${WEBSITE_PATH}
ENV JEKYLL_PORT=${JEKYLL_PORT}

# Installing packages.
RUN apk add --no-cache \
  linux-headers \
  build-base \
  libxml2-dev && \
  gem install bundler -v $BUNDLER_VERSION

# Installing gems.
COPY Gemfile* $WEBSITE_PATH/
WORKDIR $WEBSITE_PATH
RUN bundle install

COPY . $WEBSITE_PATH

EXPOSE $JEKYLL_PORT

CMD ["bundle", "exec", "jekyll", "serve", "--host", "0.0.0.0"]
