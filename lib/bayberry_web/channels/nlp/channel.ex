defmodule BayberryWeb.NLP.Channel do
  use Phoenix.Channel
  alias Bayberry.NLP.Classifier

  def join("nlp:lda", _message, socket) do
    {:ok, socket}
  end

  def join("nlp:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  intercept ["lda-search"]

  def handle_in("lda-search", %{"body" => term}, socket) do
    {:reply, {:ok, %{body: Classifier.search(term)}}, socket}
  end
end
