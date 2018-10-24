defmodule BayberryWeb.Blog.ArticleControllerTest do
  use BayberryWeb.ConnCase

  alias Bayberry.{Accounts, Blog}

  @create_attrs %{body: "some body", title: "some title", views: 42}
  @update_attrs %{body: "some updated body", title: "some updated title", views: 43}
  @invalid_attrs %{body: nil, title: nil, views: nil}
  @user_attrs %{name: "user", username: "username"}
  @author_attrs %{bio: "bio", role: "role", genre: "genre"}

  setup do
    {:ok, user} = Accounts.create_user(@user_attrs)
    {:ok, author} = Blog.create_author(user, @author_attrs)
    {:ok, article} = Blog.create_article(author, @create_attrs)
    conn = Phoenix.ConnTest.build_conn() |> assign(:current_user, user)

    {:ok, conn: conn, user: user, author: author, article: article}
  end

  describe "index" do
    test "lists all articles", %{conn: conn} do
      conn = get conn, blog_article_path(conn, :index)
      assert html_response(conn, 200) =~ "Articles"
    end
  end

  describe "new article" do
    test "renders form", %{conn: conn} do
      conn = get conn, blog_article_path(conn, :new)
      assert html_response(conn, 200) =~ "New Article"
    end
  end

  describe "create article" do
    test "redirects to show when data is valid", %{conn: conn} do
      current_user = conn.assigns.current_user
      conn = post conn, blog_article_path(conn, :create), article: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == blog_article_path(conn, :show, id)

      conn = conn |> recycle |> assign(:current_user, current_user)
      conn = get conn, blog_article_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Article"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, blog_article_path(conn, :create), article: @invalid_attrs
      assert html_response(conn, 200) =~ "New Article"
    end
  end

  describe "edit article" do
    test "renders form for editing chosen article", %{conn: conn, article: article} do
      conn = get conn, blog_article_path(conn, :edit, article)
      assert html_response(conn, 200) =~ "Edit Article"
    end
  end

  describe "update article" do
    test "redirects when data is valid", %{conn: conn, article: article} do
      current_user = conn.assigns.current_user
      conn = put conn, blog_article_path(conn, :update, article), article: @update_attrs
      assert redirected_to(conn) == blog_article_path(conn, :show, article)

      conn = conn |> recycle |> assign(:current_user, current_user)
      conn = get conn, blog_article_path(conn, :show, article)
      assert html_response(conn, 200) =~ "some updated body"
    end

    test "renders errors when data is invalid", %{conn: conn, article: article} do
      conn = put conn, blog_article_path(conn, :update, article), article: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Article"
    end
  end

  describe "delete article" do
    test "deletes chosen article", %{conn: conn, article: article} do
      current_user = conn.assigns.current_user
      conn = delete conn, blog_article_path(conn, :delete, article)
      assert redirected_to(conn) == blog_article_path(conn, :index)

      conn = conn |> recycle |> assign(:current_user, current_user)
      assert_error_sent 404, fn ->
        get conn, blog_article_path(conn, :show, article)
      end
    end
  end
end
