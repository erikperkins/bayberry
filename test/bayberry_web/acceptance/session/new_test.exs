defmodule BayberryWeb.Session.NewTest do
  import BayberryWeb.Router.Helpers
  use BayberryWeb.ConnCase
  use Hound.Helpers
  alias BayberryWeb.Endpoint
  alias Bayberry.Accounts

  setup do
    attrs = %{
      name: "test",
      username: "test",
      credential: %{email: "test@datapun.net", password: "password"}
    }

    {:ok, user} = Accounts.create_user(attrs)

    {:ok, user: user}
  end

  hound_session()

  @tag phantomjs: true
  test "valid login" do
    Endpoint
    |> session_url(:new)
    |> navigate_to()

    login = find_element(:id, "login")
    user_email = find_within_element(login, :id, "user_email")
    user_password = find_within_element(login, :id, "user_password")
    submit = find_within_element(login, :id, "submit")

    fill_field(user_email, "test@datapun.net")
    fill_field(user_password, "password")

    click(submit)

    assert current_url() == main_url(Endpoint, :index)
  end

  @tag phantomjs: true
  test "invalid login" do
    login_page = session_url(Endpoint, :new)

    Endpoint
    |> session_url(:new)
    |> navigate_to()

    login = find_element(:id, "login")
    user_email = find_within_element(login, :id, "user_email")
    user_password = find_within_element(login, :id, "user_password")
    submit = find_within_element(login, :id, "submit")

    fill_field(user_email, "invalid@email.com")
    fill_field(user_password, "invalidpassword")

    click(submit)

    alert = find_element(:xpath, ~s|//p[contains(@class, 'alert-danger')]|)
    alert_text = visible_text(alert)

    assert alert_text == "Invalid email or password"

    assert current_url() == login_page
  end
end
