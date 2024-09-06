defmodule TodoList.Accounts do
  alias TodoList.Repo
  alias TodoList.Accounts.User

  def find_or_create_user(%{email: email} = user_params) do
    case Repo.get_by(User, email: email) do
      nil ->
        %User{}
        |> User.changeset(user_params)
        |> Repo.insert()
      user ->
        {:ok, user}
    end
  end

  def get_user!(id), do: Repo.get!(User, id)

  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end
end
