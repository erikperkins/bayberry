FROM elixir:1.7

RUN apt-get update -qq && apt-get install -y \
  build-essential libssl-dev curl inotify-tools
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN apt-get install -y nodejs

ENV PHOENIX_HOME /phoenix_app
ENV MIX_ENV prod

RUN mkdir $PHOENIX_HOME
COPY . $PHOENIX_HOME

WORKDIR $PHOENIX_HOME
RUN mix local.hex --force
RUN  mix archive.install --force \
  https://github.com/phoenixframework/archives/raw/master/phx_new.ez
RUN mix local.rebar --force
RUN mix deps.get --only prod
RUN mix deps.compile

WORKDIR $PHOENIX_HOME/assets
RUN npm install
RUN node node_modules/brunch/bin/brunch build --production

WORKDIR $PHOENIX_HOME
RUN mix compile
RUN mix phx.digest

RUN chmod 755 docker-entrypoint.sh
ENTRYPOINT ["/phoenix_app/docker-entrypoint.sh"]
CMD ["mix", "phx.server"]
