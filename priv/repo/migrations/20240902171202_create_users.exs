defmodule TodoList.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string
      add :email, :string
      add :provider, :string
      add :uid, :string

      timestamps()
    end

    create unique_index(:users, [:email])
  end
end
