FROM elixir:1.5.0

RUN apt-get update -qq && apt-get install -y \
  build-essential libssl-dev curl

RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN apt-get install -y nodejs

RUN mix archive.install https://github.com/phoenixframework/archives/raw/master/phoenix_new.ez

ENV PHOENIX_HOME /phoenix_app
ENV MIX_ENV prod

RUN mkdir $PHOENIX_HOME
WORKDIR $PHOENIX_HOME

ADD . $PHOENIX_HOME

RUN mix local.hex --force
RUN mix local.rebar --force
