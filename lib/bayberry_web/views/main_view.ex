defmodule BayberryWeb.MainView do
  use BayberryWeb, :view

  def render("scripts.html", assigns) do
    case assigns.script_path do
      "/" ->
        ~S"""
        <script>require("js/main/digits").Digits.run()</script>
        <script>require("js/main/topics").Topics.run()</script>
        <script>require("js/main/visitors").Visitors.run()</script>
        <script>require("js/main/wordcloud").WordCloud.run()</script>
        """
        |> raw
      "/mnist" ->
        ~S"""
        <script>require("js/mnist/mnistsocket").MnistSocket.run()</script>
        """
        |> raw
      "/nlp" ->
        ~S"""
        <script>require("js/nlp/nlpsocket").NlpSocket.run()</script>
        """
        |> raw
      "/twitter" ->
        ~S"""
        <script>require("js/twitter/twittersocket").TwitterSocket.run()</script>
        """
        |> raw
      "/blank" ->
      ~S"""
      """
        |> raw
      _ -> nil
    end
  end
end
