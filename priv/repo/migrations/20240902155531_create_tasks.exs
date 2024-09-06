defmodule TodoList.Repo.Migrations.CreateTasks do
  use Ecto.Migration

  def up do
    create table(:tasks) do
      add :title, :string, null: false
      add :description, :text
      add :status, :string, default: "To do", null: false

      timestamps()
    end

    create index(:tasks, [:status])
  end

  def down do
    drop_if_exists index(:tasks, [:status])
    drop_if_exists table(:tasks)
  end
end
