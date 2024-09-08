defmodule TodoList.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :name, :string
    field :email, :string
    field :provider, :string
    field :uid, :string
    field :picture, :string

    has_many :tasks, TodoList.Todos.Task
    has_many :categories, TodoList.Todos.Category

    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email, :provider, :uid, :picture])
    |> put_default_name()
    |> validate_required([:name, :email, :provider, :uid, :picture])
    |> unique_constraint(:email)
  end

  defp put_default_name(changeset) do
    case get_field(changeset, :name) do
      nil ->
        email = get_field(changeset, :email)
        default_name = email |> String.split("@") |> List.first()
        put_change(changeset, :name, default_name)

      _ ->
        changeset
    end
  end
end
