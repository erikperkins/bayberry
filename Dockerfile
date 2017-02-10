FROM elixir:1.4.1

RUN curl -sL https://deb.nodesource.com/setup_6.x -o nodesource_setup.sh
RUN chmod 700 nodesource_setup.sh
RUN ./nodesource_setup.sh
RUN apt-get install -y nodejs

RUN mix archive.install https://github.com/phoenixframework/archives/raw/master/phoenix_new.ez

ENV PHOENIX_HOME /phoenix_app
ENV MIX_ENV prod

RUN mkdir $PHOENIX_HOME
WORKDIR $PHOENIX_HOME

ADD . $PHOENIX_HOME

RUN npm install
RUN $PHOENIX_HOME/node_modules/brunch/bin/brunch build --production

RUN mix local.hex --force
RUN mix local.rebar --force
RUN mix deps.get

RUN mix deps.compile
RUN mix compile
#RUN mix phoenix.digest
