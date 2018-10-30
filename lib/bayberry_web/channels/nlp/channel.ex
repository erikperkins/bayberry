defmodule BayberryWeb.NLP.Channel do
  use Phoenix.Channel
  #alias Bayberry.NLP.Classifier
  import Application, only: [get_env: 2]
  @classifier get_env(:bayberry, Bayberry.Service)[:nlp]

  def join("nlp:lda", _message, socket) do
    {:ok, socket}
  end

  def join("nlp:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  intercept ["lda-search"]

  def handle_in("lda-search", %{"body" => term}, socket) do
    {:reply, {:ok, %{body: @classifier.search(term)}}, socket}
  end
end
