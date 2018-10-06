defmodule BayberryWeb.CMS.AuthorController do
  use BayberryWeb, :controller

  alias Bayberry.CMS
  alias Bayberry.CMS.Author

  plug :authorize_author when action in [:edit, :update, :delete]

  def index(conn, _params) do
    authors = CMS.list_authors()
    render(conn, "index.html", authors: authors)
  end

  def new(conn, _params) do
    changeset = CMS.change_author(%Author{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"author" => author_params}) do
    case CMS.create_author(conn.assigns.current_user, author_params) do
      {:ok, author} ->
        conn
        |> put_flash(:info, "Author created successfully.")
        |> redirect(to: cms_author_path(conn, :show, author))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    author = CMS.get_author!(id)
    render(conn, "show.html", author: author)
  end

  def edit(conn, _) do
    changeset = CMS.change_author(conn.assigns.author)
    render(conn, "edit.html", changeset: changeset)
  end

  def update(conn, %{"author" => author_params}) do
    case CMS.update_author(conn.assigns.author, author_params) do
      {:ok, author} ->
        conn
        |> put_flash(:info, "Author updated successfully.")
        |> redirect(to: cms_author_path(conn, :show, author))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    author = CMS.get_author!(id)
    {:ok, _author} = CMS.delete_author(author)

    conn
    |> put_flash(:info, "Author deleted successfully.")
    |> redirect(to: cms_author_path(conn, :index))
  end

  defp authorize_author(conn, _) do
    author = CMS.get_author!(conn.params["id"])

    if conn.assigns.current_user.id == author.user_id do
      assign(conn, :author, author)
    else
      conn
      |> put_flash(:error, "You cannot modify that author")
      |> redirect(to: cms_author_path(conn, :index))
      |> halt()
    end
  end
end
