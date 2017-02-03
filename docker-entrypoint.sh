#!/bin/bash
mix deps.compile
mix compile
mix phoenix.digest

mix ecto.create
mix ecto.migrate
exec "$@"
