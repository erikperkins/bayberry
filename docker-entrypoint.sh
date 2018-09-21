#!/bin/bash
mix ecto.setup
exec "$@"
