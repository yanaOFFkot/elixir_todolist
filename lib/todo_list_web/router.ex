defmodule TodoListWeb.Router do
  use TodoListWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {TodoListWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", TodoListWeb do
    pipe_through :browser

    get "/", AuthController, :request
    get "/auth/:provider", AuthController, :request
    get "/auth/:provider/callback", AuthController, :callback
    get "/logout", AuthController, :logout

    resources "/tasks", TaskController
    live "/profile", UserProfileLive, :index
    live "/example", ExampleLive, :index
    live "/task-categories", TaskCategoriesLive, :index
  end

end
