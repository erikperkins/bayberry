#!/bin/bash
mix deps.get
mix deps.compile
mix compile

npm install
brunch build --production

mix phoenix.digest

mix ecto.create
mix ecto.migrate
exec "$@"
