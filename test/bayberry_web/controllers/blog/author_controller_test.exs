defmodule BayberryWeb.Blog.AuthorControllerTest do
  use BayberryWeb.ConnCase

  alias Bayberry.{Accounts, Blog}

  @create_attrs %{bio: "bio", role: "role", genre: "genre"}
  @update_attrs %{bio: "other bio", role: "other role", genre: "other genre"}
  @invalid_attrs %{bio: nil, role: nil, genre: nil}
  @user_attrs %{name: "name", username: "username"}
  @admin_attrs %{name: "admin", username: "admin"}

  setup do
    {:ok, user} = Accounts.create_user(@user_attrs)
    {:ok, admin} = Accounts.create_user(@admin_attrs)
    {:ok, author} = Blog.create_author(user, @create_attrs)
    conn =
      Phoenix.ConnTest.build_conn
      |> assign(:current_user, user)

    {:ok, conn: conn, user: user, author: author, admin: admin}
  end

  describe "index" do
    test "lists all authors", %{conn: conn} do
      conn = get conn, blog_author_path(conn, :index)
      assert html_response(conn, 200) =~ "Authors"
    end
  end

  describe "new author" do
    test "renders form", %{conn: conn} do
      conn = get conn, blog_author_path(conn, :new)
      assert html_response(conn, 200) =~ "New Author"
    end
  end

  describe "create author" do
    test "redirects to show when data is valid", %{conn: conn, admin: admin} do
      conn = assign(conn, :current_user, admin)
      current_user = conn.assigns.current_user
      conn = post conn, blog_author_path(conn, :create), author: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == blog_author_path(conn, :show, id)

      conn = conn |> recycle |> assign(:current_user, current_user)
      conn = get conn, blog_author_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Author"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, blog_author_path(conn, :create), author: @invalid_attrs
      assert html_response(conn, 200) =~ "New Author"
    end
  end

  describe "edit author" do
    test "renders form for editing chosen author", %{conn: conn, author: author} do
      conn = get conn, blog_author_path(conn, :edit, author)
      assert html_response(conn, 200) =~ "Edit Author"
    end
  end

  describe "update author" do
    test "redirects when data is valid", %{conn: conn, author: author} do
      current_user = conn.assigns.current_user
      conn = put conn, blog_author_path(conn, :update, author), author: @update_attrs
      assert redirected_to(conn) == blog_author_path(conn, :show, author)

      conn = conn |> recycle |> assign(:current_user, current_user)
      conn = get conn, blog_author_path(conn, :show, author)
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, author: author} do
      conn = put conn, blog_author_path(conn, :update, author), author: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Author"
    end
  end

  describe "delete author" do
    test "deletes chosen author", %{conn: conn, author: author} do
      conn = delete conn, blog_author_path(conn, :delete, author)
      assert redirected_to(conn) == blog_author_path(conn, :index)

      assert_error_sent 404, fn ->
        get conn, blog_author_path(conn, :show, author)
      end
    end
  end
end
