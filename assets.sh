#!/bin/bash
mix ecto.setup
cd assets
node node_modules/brunch/bin/brunch build --production
cd ..
mix phx.digest
exec "$@"
