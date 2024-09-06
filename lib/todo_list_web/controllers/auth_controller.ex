defmodule TodoListWeb.AuthController do
  use TodoListWeb, :controller
  plug Ueberauth

  alias TodoList.Accounts
  alias TodoList.Repo
  alias TodoList.Accounts.User

  plug :fetch_current_user

  def request(conn, _params) do
    if conn.assigns[:current_user] do
      redirect(conn, to: "/tasks")
    else
      render(conn, "request.html")
    end
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    user_params = %{
      provider: Atom.to_string(auth.provider),
      uid: auth.uid,
      name: auth.info.name || auth.info.email |> String.split("@") |> List.first(),
      email: auth.info.email,
      picture: auth.info.image
    }

    case Accounts.find_or_create_user(user_params) do
      {:ok, user} ->
        conn
        |> put_session(:user_id, user.id)
        |> redirect(to: "/tasks")

      {:error, changeset} ->
        conn
        |> put_flash(:error, "Failed to authenticate: #{inspect(changeset.errors)}")
        |> redirect(to: "/")
    end

    # with {:ok, user} <- Accounts.find_or_create_user(user_params) do
      # conn
      # |> put_session(:user_id, user.id)
      # |> redirect(to: "/tasks")
    # else
      # {:error, changeset} ->
       #  conn
        # |> put_flash(:error, "Failed to authenticate: #{inspect(changeset.errors)}")
        # |> redirect(to: "/")
    #end


  end

  def logout(conn, _params) do
    conn
    |> configure_session(drop: true)
    |> put_flash(:info, "You have been logged out.")
    |> redirect(to: "/")
  end

  defp fetch_current_user(conn, _opts) do
    user_id = get_session(conn, :user_id)

    if user = user_id && Repo.get(User, user_id) do
      assign(conn, :current_user, user)
    else
      assign(conn, :current_user, nil)
    end
  end
end
