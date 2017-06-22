FROM elixir:1.4.4

# RUN curl -sL https://deb.nodesource.com/setup_6.x -o nodesource_setup.sh
# RUN chmod 700 nodesource_setup.sh
# RUN ./nodesource_setup.sh

# RUN apt-get install -y nodejs

RUN apt-get -qq update

RUN apt-get install -y build-essential libssl-dev
RUN apt-get install -y npm


RUN mix archive.install https://github.com/phoenixframework/archives/raw/master/phoenix_new.ez

ENV PHOENIX_HOME /phoenix_app
ENV MIX_ENV prod

RUN mkdir $PHOENIX_HOME
WORKDIR $PHOENIX_HOME

ADD . $PHOENIX_HOME

RUN mix local.hex --force
# RUN mix local.rebar --force

#RUN wget http://s3.amazonaws.com/s3.hex.pm/installs/1.1.0/hex-0.16.0.ez
#RUN mix local.install hex-0.16.csv

RUN mix deps.get

RUN mix deps.compile
RUN mix compile
#RUN mix phoenix.digest

RUN npm install
RUN $PHOENIX_HOME/node_modules/brunch/bin/brunch build --production
