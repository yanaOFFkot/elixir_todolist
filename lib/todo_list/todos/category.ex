defmodule TodoList.Todos.Category do
  use Ecto.Schema
  import Ecto.Changeset

  schema "categories" do
    field :name, :string
    has_many :tasks, TodoList.Todos.Task
    belongs_to :user, TodoList.Accounts.User

    timestamps()
  end

  def changeset(category, attrs) do
    category
    |> cast(attrs, [:name, :user_id])
    |> validate_required([:name, :user_id])
    |> unique_constraint(:name, name: :unique_user_category_name)
  end
end
