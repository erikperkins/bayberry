defmodule PhoenixAppWeb.MainView do
  use PhoenixAppWeb, :view

  def render("scripts.html", assigns) do
    case assigns.script_path do
      "/" ->
        ~S"""
        <script>require("js/topics").LdaTopics.run()</script>
        <script>require("js/wordcloud").WordCloud.run()</script>
        """
        |> raw
      "/nlp" ->
        ~S"""
        <script>require("js/nlpsocket").NlpSocket.run()</script>
        """
        |> raw
      "/twitter" ->
        ~S"""
        <script>require("js/twitter").TwitterStream.run()</script>
        """
        |> raw
      _ -> nil
    end
  end
end
