FROM alpine:3.20

LABEL maintainer="Beth Skurrie <beth@bethesque.com>"
ARG TARGETPLATFORM
ARG PLUGIN_CLI_VERSION=0.1.2
ARG MOCK_SERVER_CLI_VERSION=1.0.6
ARG VERIFIER_CLI_VERSION=1.1.3
ARG STUB_SERVER_CLI_VERSION=0.6.0
ENV NOKOGIRI_USE_SYSTEM_LIBRARIES=1
ENV BUNDLE_SILENCE_ROOT_WARNING=1

ADD docker/gemrc /root/.gemrc
ADD docker/pact /usr/local/bin/pact

RUN apk update \
  && apk add ruby=3.3.3-r0 \
             ruby-io-console=3.3.3-r0 \
             ca-certificates=20240705-r0 \
             libressl \
             less \
             git \
  && apk add --virtual "build-dependencies" \
             build-base=0.5-r3 \
             ruby-dev=3.3.3-r0 \
             libressl-dev \
             ruby-rdoc=3.3.3-r0 \
  && gem install bundler -v "~>2.5" \
  && bundler -v \
  && bundle config build.nokogiri --use-system-libraries \
  && bundle config git.allow_insecure true \
  && gem update --system 3.5.14 \
  && gem install json -v "~>2.3" \
  && gem install bigdecimal -v "~>3.1" \
  && gem install racc -v "~>1.8" \
  && gem uninstall rubygems-update \
  && gem cleanup \
  && apk del build-dependencies \
  && rm -rf /usr/lib/ruby/gems/*/cache/* \
            /var/cache/apk/* \
            /tmp/* \
            /var/tmp/*

ENV HOME=/pact
ENV DOCKER=true
ENV BUNDLE_GEMFILE=$HOME/Gemfile
WORKDIR $HOME

ADD pact-cli.gemspec .
ADD Gemfile .
ADD Gemfile.lock .
ADD lib/pact/cli/version.rb ./lib/pact/cli/version.rb
RUN bundle config set without 'test development' \
    bundle config set deployment 'true' \
      && bundle install \
      && find /usr/lib/ruby/gems/3.3.0/gems -name Gemfile.lock -maxdepth 2 -delete
ADD docker/entrypoint.sh $HOME/entrypoint.sh
ADD bin ./bin
ADD lib ./lib
ADD example/pacts ./example/pacts

RUN case ${TARGETPLATFORM} in \
         "linux/amd64")  BIN_ARCH=x86_64  ;; \
         "linux/arm64")  BIN_ARCH=aarch64  ;; \
    esac \
    && wget -qO - https://github.com/pact-foundation/pact-stub-server/releases/download/v0.6.0/pact-stub-server-linux-${BIN_ARCH}.gz \
    | gunzip -fc > ./bin/pact-stub-server && chmod +x ./bin/pact-stub-server \
    && wget -qO - https://github.com/pact-foundation/pact-plugins/releases/download/pact-plugin-cli-v0.1.2/pact-plugin-cli-linux-${BIN_ARCH}.gz \
    | gunzip -fc > ./bin/pact-plugin-cli && chmod +x ./bin/pact-plugin-cli  \
    && wget -qO - https://github.com/pact-foundation/pact-reference/releases/download/pact_verifier_cli-v1.1.3/pact_verifier_cli-linux-${BIN_ARCH}.gz \
    | gunzip -fc > ./bin/pact_verifier_cli && chmod +x ./bin/pact_verifier_cli \
    && wget -qO - https://github.com/pact-foundation/pact-core-mock-server/releases/download/pact_mock_server_cli-v1.0.6/pact_mock_server_cli-linux-${BIN_ARCH}.gz \
    | gunzip -fc > ./bin/pact_mock_server_cli && chmod +x ./bin/pact_mock_server_cli
    # && wget -qO - https://github.com/pact-foundation/pact-stub-server/releases/download/v{STUB_SERVER_CLI_VERSION}/pact-stub-server-linux-${BIN_ARCH}.gz  \
    # | gunzip -fc > ./bin/pact-stub-server-linux-${BIN_ARCH} && chmod +x ./bin/pact-stub-server \
    # && wget -qO - https://github.com/pact-foundation/pact-plugins/releases/download/pact-plugin-cli-v${PLUGIN_CLI_VERSION}/pact-plugin-cli-linux-${BIN_ARCH}.gz \
    # | gunzip -fc > ./bin/pact-plugin-cli && chmod +x ./bin/pact-plugin-cli  \
    # && wget -qO - https://github.com/pact-foundation/pact-reference/releases/download/pact_verifier_cli-v{VERIFIER_CLI_VERSION}/pact_verifier_cli-linux-${BIN_ARCH}.gz \
    # | gunzip -fc > ./bin/pact_verifier_cli && chmod +x ./bin/pact_verifier_cli \
    # && wget -qO - https://github.com/pact-foundation/pact-core-mock-server/releases/download/pact_mock_server_cli-v{MOCK_SERVER_CLI_VERSION}/pact_mock_server_cli-linux-${BIN_ARCH}.gz \
    # | gunzip -fc > ./bin/pact_mock_server_cli && chmod +x ./bin/pact_mock_server_cli


ENTRYPOINT ["/pact/entrypoint.sh"]
CMD ["pact"]