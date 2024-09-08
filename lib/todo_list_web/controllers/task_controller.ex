defmodule TodoListWeb.TaskController do
  use TodoListWeb, :controller

  alias TodoList.Todos
  alias TodoList.Todos.Task
  alias TodoList.Accounts

  plug :fetch_current_user

  def index(conn, _params) do
    user = conn.assigns[:current_user]

    if user do
      tasks = Todos.list_tasks_for_user(user.id)
      render(conn, "index.html", tasks: tasks)
    else
      conn
      |> put_flash(:error, "You must be logged in to view tasks.")
      |> redirect(to: ~p"/")
    end
  end

  def new(conn, _params) do
    user = conn.assigns[:current_user]

    if user do
      changeset = Todos.change_task(%Task{})
      categories = Todos.list_categories_for_user(user.id)
      render(conn, :new, changeset: changeset, categories: categories, action: ~p"/tasks")
    else
      conn
      |> put_flash(:error, "You must be logged in to create tasks.")
      |> redirect(to: ~p"/")
    end
  end

  def create(conn, %{"task" => task_params}) do
    user = conn.assigns[:current_user]

    if user do
      task_params = Map.put(task_params, "user_id", user.id)

      case Todos.create_task(task_params) do
        {:ok, task} ->
          conn
          |> put_flash(:info, "Task created successfully.")
          |> redirect(to: ~p"/tasks/#{task.id}")

        {:error, %Ecto.Changeset{} = changeset} ->
          categories = Todos.list_categories_for_user(user.id)
          render(conn, :new, changeset: changeset, categories: categories, action: ~p"/tasks")
      end
    else
      conn
      |> put_flash(:error, "You must be logged in to create tasks.")
      |> redirect(to: ~p"/")
    end
  end


  def show(conn, %{"id" => id}) do
    task = Todos.get_task!(id)
    render(conn, :show, task: task)
  end

  def edit(conn, %{"id" => id}) do
    task = Todos.get_task!(id)
    categories = Todos.list_categories_for_user(conn.assigns[:current_user].id) # Загружаем категории для редактирования
    changeset = Todos.change_task(task)
    render(conn, :edit, task: task, changeset: changeset, categories: categories)
  end

  def update(conn, %{"id" => id, "task" => task_params}) do
    task = Todos.get_task!(id)

    case Todos.update_task(task, task_params) do
      {:ok, task} ->
        conn
        |> put_flash(:info, "Task updated successfully.")
        |> redirect(to: ~p"/tasks/#{task}")

      {:error, %Ecto.Changeset{} = changeset} ->
        categories = Todos.list_categories_for_user(conn.assigns[:current_user].id)
        render(conn, :edit, task: task, changeset: changeset, categories: categories)
    end
  end

  def delete(conn, %{"id" => id}) do
    task = Todos.get_task!(id)
    {:ok, _task} = Todos.delete_task(task)

    conn
    |> put_flash(:info, "Task deleted successfully.")
    |> redirect(to: ~p"/tasks")
  end

  defp fetch_current_user(conn, _opts) do
    user_id = get_session(conn, :user_id)

    if user = user_id && Accounts.get_user!(user_id) do
      assign(conn, :current_user, user)
    else
      assign(conn, :current_user, nil)
    end
  end
end
