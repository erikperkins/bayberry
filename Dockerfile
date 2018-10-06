FROM elixir:1.7

RUN apt-get update -qq && apt-get install -y \
  build-essential libssl-dev curl inotify-tools
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN apt-get install -y nodejs

ENV BAYBERRY_HOME /bayberry
ENV MIX_ENV prod

RUN mkdir $BAYBERRY_HOME
COPY . $BAYBERRY_HOME

WORKDIR $BAYBERRY_HOME
RUN mix local.hex --force
RUN  mix archive.install --force \
  https://github.com/phoenixframework/archives/raw/master/phx_new.ez
RUN mix local.rebar --force
RUN mix deps.get --only prod
RUN mix deps.compile

WORKDIR $BAYBERRY_HOME/assets
RUN npm install

WORKDIR $BAYBERRY_HOME
RUN mix compile

RUN chmod 755 assets.sh
ENTRYPOINT ["/bayberry/assets.sh"]
CMD ["mix", "phx.server"]
