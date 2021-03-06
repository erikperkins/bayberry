defmodule Bayberry.Twitter.Stream do
  use GenServer
  require Logger
  import Application, only: [get_env: 2]
  alias BayberryWeb.Endpoint

  @rabbitmq get_env(:bayberry, Bayberry.Service)[:rabbitmq]
  @redis get_env(:bayberry, Bayberry.Service)[:redis]
  @queue "tweets"
  @ttl 5000

  def start_link do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(%{}) do
    @rabbitmq.consume(@queue, arguments())
  end

  def handle_info({:basic_consume_ok, _meta}, channel) do
    {:noreply, channel}
  end

  def handle_info({:basic_cancel, _meta}, channel) do
    {:stop, :normal, channel}
  end

  def handle_info({:basic_cancel_ok, _meta}, channel) do
    {:stop, :normal, channel}
  end

  def handle_info({:basic_deliver, payload, _meta}, channel) do
    spawn(fn -> consume(payload, channel) end)
    {:noreply, channel}
  end

  def handle_info({:DOWN, _ref , :process, _pid, _reason}, _) do
    {:ok, channel} = @rabbitmq.consume(@queue)
    {:noreply, channel}
  end

  defp arguments() do
    message_ttl =
      case get_env(:bayberry, :rabbitmq)[:message_ttl] do
        ttl when not is_nil(ttl) -> String.to_integer(ttl)
        _ -> @ttl
      end

    [{"x-message-ttl", message_ttl}]
  end

  defp consume(payload, _channel) do
    case Jason.decode(payload) do
      {:ok, tweet} -> spawn(fn -> broadcast(tweet) end)
      {:error, error} -> Logger.error("#{error} :#{payload}")
    end
  end

  defp broadcast(%{"text" => text}) do
    text
    |> track()
    |> hyperlink()
    |> hashtag()
    |> atmention()
    |> (&Regex.replace(~r/\n|\r/, &1, "\n")).()
    |> (&Endpoint.broadcast("twitter:stream", "tweet", %{body: &1} || %{})).()
  rescue
    Jason.EncodeError -> Logger.warn("Could not broadcast tweet:\n#{text}\n")
  end

  defp hyperlink(text) do
    link_regex = ~r/(https?:\/\/([-\w\.]+)+(:\d+)?(\/([\w\/_\.]*(\?\S+)?)?)?)/iu
    link = ~s[<a href='\\1' target='_blank'>\\1</a>]
    Regex.replace(link_regex, text, link)
  end

  defp hashtag(text) do
    hashtag_regex = ~r/\#([\w]+)?/iu
    hashtag = ~s[<a href="https://twitter.com/hashtag/\\1?src=hash" target="_blank">#\\1</a>]
    Regex.replace(hashtag_regex, text, hashtag)
  end

  defp atmention(text) do
    atmention_regex = ~r/\@([\w]+)?/iu
    atmention = ~s[<a href="https://twitter.com/\\1" target="_blank">@\\1</a>]
    Regex.replace(atmention_regex, text, atmention)
  end

  defp track(text) do
    {:ok, keywords} = @redis.command(:redix, ["get", "twitter:track"])
    patterns =
      keywords
      |> String.split(",")
      |> Enum.join("|")

    track_regex = ~r/(#{patterns})/iu
    track = ~s[<strong class="track">\\1</strong>]
    Regex.replace(track_regex, text, track)
  end
end
