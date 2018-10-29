defmodule BayberryWeb.Blog.ArticleController do
  use BayberryWeb, :controller

  alias Bayberry.Blog
  alias Bayberry.Blog.Article

  plug :require_existing_author
  plug :authorize_article when action in [:edit, :update, :delete]

  def index(conn, _params) do
    articles = Blog.list_articles()
    render(conn, "index.html", articles: articles)
  end

  def new(conn, _params) do
    changeset = Blog.change_article(%Article{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"article" => article_params}) do
    case Blog.create_article(conn.assigns.current_author, article_params) do
      {:ok, article} ->
        conn
        |> put_flash(:info, "Article created successfully.")
        |> redirect(to: blog_article_path(conn, :show, article))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    article = Blog.get_article!(id)
    render(conn, "show.html", article: article)
  end

  def edit(conn, _) do
    changeset = Blog.change_article(conn.assigns.article)
    render(conn, "edit.html", changeset: changeset)
  end

  def update(conn, %{"article" => article_params}) do
    case Blog.update_article(conn.assigns.article, article_params) do
      {:ok, article} ->
        conn
        |> put_flash(:info, "Article updated successfully.")
        |> redirect(to: blog_article_path(conn, :show, article))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", changeset: changeset)
    end
  end

  def delete(conn, _) do
    {:ok, _article} = Blog.delete_article(conn.assigns.article)

    conn
    |> put_flash(:info, "Article deleted successfully.")
    |> redirect(to: blog_article_path(conn, :index))
  end

  defp require_existing_author(conn, _) do
    author = Blog.ensure_author_exists(conn.assigns.current_user)
    assign(conn, :current_author, author)
  end

  defp authorize_article(conn, _) do
    article = Blog.get_article!(conn.params["id"])

    if conn.assigns.current_author.id == article.author_id do
      assign(conn, :article, article)
    else
      conn
      |> put_flash(:error, "You cannot modify that article")
      |> redirect(to: blog_article_path(conn, :index))
      |> halt
    end
  end
end
