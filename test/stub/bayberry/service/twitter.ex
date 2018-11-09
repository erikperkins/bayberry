defmodule Stub.Bayberry.Service.Twitter do
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

  def produce(%{channel: channel} = state) do
    payload = Poison.encode!(%{text: stub()})
    @rabbitmq.publish(channel, "", "tweets", payload)

    (for a <- 20..500, do: a)
    |> Enum.random()
    |> Process.sleep()

    produce(state)
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

  defp stub() do
    case Enum.random(for a <- 0..3, do: a) do
      0 ->
        """
        @Wikipedia My existence is amazing, and I want to study algebra.
        https://wikipedia.org #wikipedia
        """
      1 ->
        """
        My newest outfit is hard labor, and I want to slow down.
        The world has clammy beats, kinda. #goodrant #randomtweet
        """
      2 ->
        """
        My inheritance is a disaster, and I want to see the world.
        We need perfect software, kinda. #bubblegate #randomtweet
        My diet is annoying everyone, and I want to be heard.
        Excellent well planned weather, IMHO. #powerrant #randomtweet
        """
      3 ->
        """
        My ringtone is a fairytale, and I want to get ahead.
        A bit of hand crafted lies, again. #midnightbling #randomtweet
        My cooking is an institution, and I want to be heard.
        Ridiculously thirsty traffic, man. #bunnywad #randomtweet
        My intelligence is a joy, and I want to learn everything.
        The world has strange pets, I say. #yolo2u #randomtweet
        """
    end
  end
end
