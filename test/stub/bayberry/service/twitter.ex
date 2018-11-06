defmodule Stub.Bayberry.Service.Twitter do
  import Application, only: [get_env: 2]
  alias BayberryWeb.Endpoint

  @rabbitmq get_env(:bayberry, Bayberry.Service)[:rabbitmq]

  def broadcast(%{"text" => text}) do
    Endpoint.broadcast("twitter:stream", "tweet", %{body: text} || %{})
  end

  def produce(%{channel: channel} = state) do
    payload = Poison.encode!(%{text: stub()})
    @rabbitmq.publish(channel, "", "tweets", payload)

    Process.sleep(500)
    produce(state)
  end

  defp stub() do
    case Enum.random([0, 1, 2, 3]) do
      0 ->
        """
        My existence is amazing, and I want to study algebra.
        Ridiculously derailed candy, please. #happytag #randomtweet
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
        """
    end
  end
end
