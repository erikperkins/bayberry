defmodule BayberryWeb.MainControllerTest do
  use BayberryWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "a small basket for berries"
  end
end
