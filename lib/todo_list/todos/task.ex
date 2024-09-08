defmodule TodoList.Todos.Task do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tasks" do
    field :title, :string
    field :description, :string
    field :status, :string, default: "Not Started"
    belongs_to :user, TodoList.Accounts.User
    belongs_to :category, TodoList.Todos.Category

    timestamps()
  end

  def changeset(task, attrs) do
    task
    |> cast(attrs, [:title, :description, :status, :user_id, :category_id])
    |> validate_required([:title, :status, :user_id])
  end
end
