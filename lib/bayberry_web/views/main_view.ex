defmodule BayberryWeb.MainView do
  use BayberryWeb, :view

  def render("scripts.html", assigns) do
    case assigns.script_path do
      "/" ->
        ~S"""
        <script>require("js/topics").LdaTopics.run()</script>
        <script>require("js/wordcloud").WordCloud.run()</script>
        """
        |> raw
      "/mnist" ->
        ~S"""
        <script>require("js/socket/mnistsocket").MnistSocket.run()</script>
        """
        |> raw
      "/nlp" ->
        ~S"""
        <script>require("js/socket/nlpsocket").NlpSocket.run()</script>
        """
        |> raw
      "/twitter" ->
        ~S"""
        <script>require("js/socket/twittersocket").TwitterSocket.run()</script>
        """
        |> raw
        "/visage" ->
          ~S"""
          <script>require("js/socket/visagesocket").VisageSocket.run()</script>
          """
          |> raw
      _ -> nil
    end
  end
end
