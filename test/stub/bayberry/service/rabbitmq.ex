defmodule Stub.Bayberry.Service.RabbitMQ do
  alias AMQP.Channel

  def declare(_queue) do
    state = %{channel: %Channel{}}
    {:ok, state}
  end

  def consume(_queue) do
    {:ok, %Channel{}}
  end

  def publish(_channel, _exchange, _queue, payload) do
    message = {:basic_deliver, payload, %{}}
    Process.send(Bayberry.Twitter.Stream, message, [])
  end

  defp produce() do
    payload = Jason.encode!(%{text: stub()})
    publish(%Channel{}, "", "tweets", payload)

    (for a <- 20..500, do: a)
    |> Enum.random()
    |> Process.sleep()

    produce()
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
