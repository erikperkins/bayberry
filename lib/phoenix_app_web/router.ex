defmodule PhoenixAppWeb.Router do
  use PhoenixAppWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", PhoenixAppWeb do
    pipe_through :browser

    get "/", MainController, :index
    get "/twitter", MainController, :twitter
    get "/architecture", MainController, :architecture
    get "/mnist", MainController, :mnist 
    get "/nlp", MainController, :nlp
    get "/word_cloud", MainController, :word_cloud

    resources "/users", UserController
    resources "/sessions", SessionController,
      only: [:new, :create, :update, :delete], singleton: true
  end

  scope "/blog", PhoenixAppWeb, as: :blog do
    pipe_through :browser

    resources "/posts", PostController, only: [:index, :show]
  end

  scope "/cms", PhoenixAppWeb.CMS, as: :cms do
    pipe_through [:browser, :authenticate_user]

    resources "/pages", PageController
    resources "/authors", AuthorController
  end

  defp authenticate_user(conn, _) do
    case get_session(conn, :user_id) do
      nil ->
        conn
        |> put_session(:redirect_url, conn.request_path)
        |> Phoenix.Controller.put_flash(:error, "Login required")
        |> Phoenix.Controller.redirect(to: "/sessions/new")
        |> halt()
      user_id ->
        assign(conn, :current_user, PhoenixApp.Accounts.get_user!(user_id))
    end
  end
end
