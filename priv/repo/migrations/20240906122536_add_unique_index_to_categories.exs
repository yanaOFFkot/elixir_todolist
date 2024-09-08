defmodule TodoList.Repo.Migrations.AddUniqueIndexToCategories do
  use Ecto.Migration

  def change do
    create unique_index(:categories, [:user_id, :name], name: :unique_user_category_name)
  end
end
