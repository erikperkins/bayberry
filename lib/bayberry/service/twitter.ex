defmodule Bayberry.Service.Twitter do
  require Logger
  import Application, only: [get_env: 2]
  alias BayberryWeb.Endpoint

  @rabbitmq get_env(:bayberry, Bayberry.Service)[:rabbitmq]

  def broadcast(%{"text" => text}) do
    text
    |> hyperlink()
    |> hashtag()
    |> atmention()
    |> (&Regex.replace(~r/\n|\r/, &1, "\n")).()
    |> (&Endpoint.broadcast("twitter:stream", "tweet", %{body: &1} || %{})).()
  end

  def produce(state) do
    Logger.warn("Receiving tweets ...")

    filters = [follow: get_env(:bayberry, :twitter)[:feed], language: "en"]
    timeout = get_env(:bayberry, :twitter)[:timeout]

    for tweet <- ExTwitter.stream_filter(filters, timeout) do
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

  defp hyperlink(text) do
    link_regex = ~r/(https?:\/\/([-\w\.]+)+(:\d+)?(\/([\w\/_\.]*(\?\S+)?)?)?)/
    link = "<a href='\\1' target='_blank'>\\1</a>"
    Regex.replace(link_regex, text, link)
  end

  defp hashtag(text) do
    hashtag_regex = ~r/\#([\w]+)?/
    hashtag = ~s[<a href="https://twitter.com/hashtag/\\1?src=hash" target="_blank">#\\1</a>]
    Regex.replace(hashtag_regex, text, hashtag)
  end

  defp atmention(text) do
    atmention_regex = ~r/\@([\w]+)?/
    atmention = ~s[<a href="https://twitter.com/\\1" target="_blank">@\\1</a>]
    Regex.replace(atmention_regex, text, atmention)
  end
end
