#!/bin/bash
mix ecto.setup
cd assets
npm rebuild node-sass
node node_modules/brunch/bin/brunch build --production
cd ..
mix phx.digest
exec "$@"
