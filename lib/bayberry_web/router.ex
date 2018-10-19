defmodule BayberryWeb.Router do
  use BayberryWeb, :router

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

  pipeline :analytics do
    plug :geolocate
  end

  scope "/", BayberryWeb do
    pipe_through [:browser, :analytics]

    get "/", MainController, :index
    get "/twitter", MainController, :twitter
    get "/architecture", MainController, :architecture
    get "/mnist", MainController, :mnist
    get "/nlp", MainController, :nlp

    resources "/sessions", SessionController,
      only: [:new, :create, :update, :delete], singleton: true
  end

  scope "/", BayberryWeb do
    pipe_through :browser

    get "/word_cloud", MainController, :word_cloud
  end

  scope "/accounts", BayberryWeb.Accounts, as: :accounts do
    pipe_through [:browser, :authenticate_user, :analytics]

    get "/administration/", AdministrationController, :index
    get "/administration/visitors", AdministrationController, :visitors
    resources "/users", UserController
  end

  scope "/accounts", BayberryWeb.Accounts, as: :accounts do
    pipe_through [:browser, :authenticate_user]

    get "/administration/world_map", AdministrationController, :world_map
    get "/administration/locations", AdministrationController, :locations
  end

  scope "/blog", BayberryWeb, as: :blog do
    pipe_through [:browser, :analytics]

    resources "/posts", PostController, only: [:index, :show]
  end

  scope "/blog", BayberryWeb.Blog, as: :blog do
    pipe_through [:browser, :authenticate_user]

    resources "/articles", ArticleController
    resources "/authors", AuthorController
  end

  defp geolocate(conn, _) do
    conn
    |> Bayberry.Administration.record_visit
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
        assign(conn, :current_user, Bayberry.Accounts.get_user!(user_id))
    end
  end
end
