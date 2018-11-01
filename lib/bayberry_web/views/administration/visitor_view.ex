defmodule BayberryWeb.Administration.VisitorView do
  use BayberryWeb, :view

  def render("scripts.html", assigns) do
    case assigns.script_path do
      "/administration/visitors" ->
        ~S"""
        <script>require("js/socket/visitors").VisitorMap.run()</script>
        """
        |> raw
      _ -> nil
    end
  end
end
