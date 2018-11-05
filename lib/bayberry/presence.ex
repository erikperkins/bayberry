defmodule Bayberry.Presence do
  use Phoenix.Presence, otp_app: :bayberry, pubsub_server: Bayberry.PubSub
end
