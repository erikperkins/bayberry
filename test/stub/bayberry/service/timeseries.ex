defmodule Stub.Bayberry.Service.Timeseries do
  alias BayberryWeb.Endpoint

  def forecast() do
      timeseries = %{
        predicted: [
          %{time: 1540943220, datum: 20},
          %{time: 1540943280, datum: 41.5},
          %{time: 1540943340, datum: 63.25}
        ],
        observed: [
          %{time: 1540943220, datum: 63},
          %{time: 1540943280, datum: 85},
          %{time: 1540943340, datum: Timex.now.second}
        ]
      }

    Endpoint.broadcast("twitter:stream", "timeseries", timeseries)
  end

  def count(tweet) do
    {:ok, tweet}
  end
end
