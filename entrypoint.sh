#!/bin/bash
mix ecto.setup
cd assets
npm rebuild node-sass
cd ..
mix phx.assets
exec "$@"
