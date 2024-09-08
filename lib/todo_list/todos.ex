defmodule TodoList.Todos do
  import Ecto.Query, only: [from: 2]
  alias TodoList.Repo
  alias TodoList.Todos.{Task, Category}

  def list_tasks_for_user(user_id) do
    from(t in Task,
      where: t.user_id == ^user_id,
      preload: [:category]
    )
    |> Repo.all()
  end

  def list_tasks do
    from(t in Task, preload: [:category])
    |> Repo.all()
  end

  def get_task!(id) do
    from(t in Task,
      where: t.id == ^id,
      preload: [:category]
    )
    |> Repo.one!()
  end

  def create_task(attrs \\ %{}) do
    %Task{}
    |> Task.changeset(attrs)
    |> Repo.insert()
  end

  def update_task(%Task{} = task, attrs) do
    task
    |> Task.changeset(attrs)
    |> Repo.update()
  end

  def delete_task(%Task{} = task) do
    Repo.delete(task)
  end

  def change_task(%Task{} = task, attrs \\ %{}) do
    Task.changeset(task, attrs)
  end

  def list_categories_for_user(user_id) do
    from(c in Category,
      where: c.user_id == ^user_id,
      preload: [:user]
    )
    |> Repo.all()
  end

  def get_category!(id) do
    Repo.get!(Category, id)
  end

  def create_category(attrs \\ %{}) do
    %Category{}
    |> Category.changeset(attrs)
    |> Repo.insert()
  end

  def update_category(%Category{} = category, attrs) do
    category
    |> Category.changeset(attrs)
    |> Repo.update()
  end

  def delete_category(%Category{} = category) do
    Repo.delete(category)
  end

  def change_category(%Category{} = category, attrs \\ %{}) do
    Category.changeset(category, attrs)
  end
end
