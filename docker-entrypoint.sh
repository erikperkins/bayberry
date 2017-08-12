#!/bin/bash
mix phoenix.digest -o ./priv/static

mix ecto.create
mix ecto.migrate
exec "$@"
