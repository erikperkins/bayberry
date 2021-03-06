defmodule BayberryWeb.Router do
  use BayberryWeb, :router
  import Application, only: [get_env: 2]
  @authentication get_env(:bayberry, BayberryWeb.Plugs)[:authorization]
  @geolocation get_env(:bayberry, BayberryWeb.Plugs)[:geolocation]
  @csp ~s(script-src 'self' 'unsafe-eval'; style-src 'self' 'unsafe-inline';)

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers, %{"content-security-policy" => @csp}
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :analytics do
    plug @geolocation
  end

  pipeline :authentication do
    plug @authentication
  end

  scope "/", BayberryWeb do
    pipe_through [:browser, :analytics]

    get "/", MainController, :index
    get "/twitter", MainController, :twitter
    get "/architecture", MainController, :architecture
    get "/mnist", MainController, :mnist
    get "/nlp", MainController, :nlp
    get "/blank", MainController, :blank
  end

  scope "/", BayberryWeb do
    pipe_through :browser

    resources "/session", SessionController,
      only: [:new, :create, :update, :delete],
      singleton: true
  end

  scope "/api", BayberryWeb do
    pipe_through :api

    get "/architecture", ResourceController, :architecture
    get "/topics", ResourceController, :topics
    get "/word_cloud", ResourceController, :word_cloud
    get "/world_map", ResourceController, :world_map
  end

  scope "/administration", BayberryWeb.Administration, as: :administration do
    pipe_through [:browser, :authentication]

    get "/", DashboardController, :index
  end

  scope "/accounts", BayberryWeb.Accounts, as: :accounts do
    pipe_through [:browser, :authentication]

    resources "/users", UserController
  end

  scope "/blog", BayberryWeb.Blog, as: :blog do
    pipe_through [:browser, :analytics]

    get "/posts", ArticleController, :posts
    get "/posts/:slug", ArticleController, :posts
    get "/contains/:slug", ArticleController, :contains
    get "/post/:id", ArticleController, :post
  end

  scope "/blog", BayberryWeb.Blog, as: :blog do
    pipe_through [:browser, :authentication]

    resources "/articles", ArticleController
    resources "/authors", AuthorController
  end
end
