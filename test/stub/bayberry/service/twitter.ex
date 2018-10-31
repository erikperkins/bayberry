defmodule Stub.Bayberry.Service.Twitter do
  import Application, only: [get_env: 2]
  alias BayberryWeb.Endpoint

  @rabbitmq get_env(:bayberry, Bayberry.Service)[:rabbitmq]

  def broadcast(%{"text" => text}) do
    Endpoint.broadcast("twitter:stream", "tweet", %{body: text} || %{})
  end

  def produce(%{channel: channel} = state) do
    payload = Poison.encode!(%{text: "tweet stub"})
    @rabbitmq.publish(channel, "", "tweets", payload)

    Process.sleep(500)
    produce(state)
  end
end
