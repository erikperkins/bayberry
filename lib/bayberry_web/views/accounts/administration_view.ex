defmodule BayberryWeb.Accounts.AdministrationView do
  use BayberryWeb, :view

  def render("scripts.html", assigns) do
    case assigns.script_path do
      "/accounts/administration/visitors" ->
        ~S"""
        <script>require("js/visitors").VisitorMap.run()</script>
        """
        |> raw
      _ -> nil
    end
  end
end
