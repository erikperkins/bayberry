defmodule BayberryWeb.UserControllerTest do
  use BayberryWeb.ConnCase

  alias Bayberry.Accounts

  @credential_attrs %{email: "email", password: "password"}
  @create_attrs %{name: "some name", username: "some username", credential: @credential_attrs}
  @update_attrs %{name: "some updated name", username: "some updated username"}
  @invalid_attrs %{name: nil, username: nil}

  def fixture(:user, attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(@create_attrs)
      |> Accounts.create_user

    user
  end

  describe "index" do
    test "lists all users", %{conn: conn} do
      conn = get conn, accounts_user_path(conn, :index)
      assert html_response(conn, 200) =~ "Users"
    end
  end

  describe "new user" do
    test "renders form", %{conn: conn} do
      conn = get conn, accounts_user_path(conn, :new)
      assert html_response(conn, 200) =~ "New User"
    end
  end

  describe "create user" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, accounts_user_path(conn, :create), user: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == accounts_user_path(conn, :show, id)

      conn = get conn, accounts_user_path(conn, :show, id)
      assert html_response(conn, 200) =~ @create_attrs.name
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, accounts_user_path(conn, :create), user: @invalid_attrs
      assert html_response(conn, 200) =~ "New User"
    end
  end

  describe "edit user" do
    setup [:create_user]

    test "renders form for editing chosen user", %{conn: conn, user: user} do
      conn = get conn, accounts_user_path(conn, :edit, user)
      assert html_response(conn, 200) =~ "Edit User"
    end
  end

  describe "update user" do
    setup [:create_user]

    test "redirects when data is valid", %{conn: conn, user: user} do
      conn = put conn, accounts_user_path(conn, :update, user), user: @update_attrs
      assert redirected_to(conn) == accounts_user_path(conn, :show, user)

      conn = get conn, accounts_user_path(conn, :show, user)
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn = put conn, accounts_user_path(conn, :update, user), user: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit User"
    end
  end

  describe "delete user" do
    setup [:create_user, :create_admin]

    test "deletes chosen user", %{conn: conn, user: user, admin: admin} do # failing
      conn = assign(conn, :current_user, admin)

      conn = delete conn, accounts_user_path(conn, :delete, user)
      assert redirected_to(conn) == accounts_user_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, accounts_user_path(conn, :show, user)
      end
    end
  end

  defp create_user(_) do
    user = fixture(:user)
    {:ok, user: user}
  end

  defp create_admin(_) do
    attrs = %{
      username: "admin",
      credential: %{email: "admin", password: "password"}
    }
    admin = fixture(:user, attrs)
    {:ok, admin: admin}
  end
end
