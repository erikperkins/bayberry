defmodule Bayberry.Service.Twitter do
  require Logger
  import Application, only: [get_env: 2]
  alias BayberryWeb.Endpoint

  @follow "25073877"
  @rabbitmq get_env(:bayberry, Bayberry.Service)[:rabbitmq]

  def broadcast(%{"text" => text}) do
    link = ~r/(https?:\/\/([-\w\.]+)+(:\d+)?(\/([\w\/_\.]*(\?\S+)?)?)?)/

    text
    |> (&Regex.replace(~r/\n|\r/, &1, "\n")).()
    |> (&Regex.replace(link, &1, "<a href='\\1' target='_blank'>\\1</a>")).()
    |> (&Endpoint.broadcast("twitter:stream", "tweet", %{body: &1} || %{})).()
  end

  def produce(state) do
    Logger.warn("Receiving tweets...")
    filters = [follow: @follow, language: "en"]

    for tweet <- ExTwitter.stream_filter(filters, 10000) do
      tweet
      |> extend_tweet
      |> publish(state)
    end

    Logger.warn("Twitter stream stopped. Restarting stream...")
    send(self(), :stream)
  end

  defp extend_tweet(tweet) do
    case tweet do
      %{extended_tweet: %{full_text: full_text}} ->
        %{created_at: tweet.created_at, text: full_text}

      _ ->
        %{created_at: tweet.created_at, text: tweet.text}
    end
  end

  defp publish(tweet, %{channel: channel}) do
    case Poison.encode(tweet) do
      {:ok, payload} -> @rabbitmq.publish(channel, "", "tweets", payload)
      _ -> Logger.error("Could not encode tweet")
    end
  end
end
