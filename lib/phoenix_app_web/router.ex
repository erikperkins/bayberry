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
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/twitter", TwitterController, :index
    resources "/users", UserController
    resources "/sessions", SessionController, only: [:new, :create, :delete],
      singleton: true
  end

  # Other scopes may use custom stacks.
  # scope "/api", PhoenixAppWeb do
  #   pipe_through :api
  # end
  defp authenticate_user(conn, _) do
    case get_session(conn, :user_id) do
      nil ->
        conn
        |> Phoenix.Controller.put_flash(:error, "Login required")
        |> Phoenix.Controller.redirect(to: "/")
        |> halt()
      user_id ->
        assign(conn, :current_user, PhoenixApp.Accounts.get_user!(user_id))
    end
  end
end
