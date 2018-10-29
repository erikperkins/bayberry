#!/bin/bash
mix ecto.setup
mix run priv/repo/seeds.exs
cd assets
npm rebuild node-sass
cd ..
mix phx.assets
exec "$@"
