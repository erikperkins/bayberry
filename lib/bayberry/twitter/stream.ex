defmodule Bayberry.Twitter.Stream do
  use GenServer
  require Logger
  import Application, only: [get_env: 2]
  alias BayberryWeb.Endpoint

  @rabbitmq get_env(:bayberry, Bayberry.Service)[:rabbitmq]

  def start_link do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(%{}) do
    @rabbitmq.consume("tweets")
  end

  def handle_info({:basic_consume_ok, _meta}, channel) do
    {:noreply, channel}
  end

  def handle_info({:basic_cancel, _meta}, channel) do
    {:stop, :normal, channel}
  end

  def handle_info({:basic_deliver, payload, _meta}, channel) do
    spawn(fn -> consume(payload, channel) end)
    {:noreply, channel}
  end

  defp consume(payload, _channel) do
    case Jason.decode(payload) do
      {:ok, tweet} -> spawn(fn -> broadcast(tweet) end)
      _ -> Logger.error("Could not decode tweet")
    end
  end

  defp broadcast(%{"text" => text}) do
    text
    |> hyperlink()
    |> hashtag()
    |> atmention()
    |> (&Regex.replace(~r/\n|\r/, &1, "\n")).()
    |> (&Endpoint.broadcast("twitter:stream", "tweet", %{body: &1} || %{})).()
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
