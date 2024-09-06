defmodule TodoListWeb.Plugs.AuthenticateUser do
  import Plug.Conn

  def init(default), do: default

  def call(conn, _opts) do
    if get_session(conn, :user_id) do
      conn
    else
      conn
      |> Phoenix.Controller.put_flash(:error, "You must be logged in to access this page.")
      |> Phoenix.Controller.redirect(to: "/")
      |> halt()
    end
  end
end
