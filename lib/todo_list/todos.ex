defmodule TodoList.Todos do
  import Ecto.Query, only: [from: 2]
  alias TodoList.Repo
  alias TodoList.Todos.Task

  def list_tasks_for_user(user_id) do
    Repo.all(from t in Task, where: t.user_id == ^user_id)
    |> Repo.preload(:user)
  end

  def list_tasks do
    Repo.all(Task)
  end

  def get_task!(id), do: Repo.get!(Task, id)

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
end
