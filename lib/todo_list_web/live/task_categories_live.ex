defmodule TodoListWeb.TaskCategoriesLive do
  use Surface.LiveView
  alias TodoList.Todos
  alias TodoList.Todos.Category
  alias TodoListWeb.Components.{CategoryForm, CategoryList, CategoryCounter}

  def mount(_params, session, socket) do
    user_id = session["user_id"]

    if user_id do
      categories = Todos.list_categories_for_user(user_id)
      changeset = Todos.change_category(%Category{user_id: user_id})

      socket =
        socket
        |> assign(current_user_id: user_id, categories: categories)
        |> assign(form: to_form(changeset))

      {:ok, socket}
    else
      {:ok, redirect(socket, to: "/")}
    end
  end

  def handle_event("add_category", %{"category" => category_params}, socket) do
    category_params = Map.put(category_params, "user_id", socket.assigns.current_user_id)

    case Todos.create_category(category_params) do
      {:ok, category} ->
        updated_categories = [category | socket.assigns.categories]
        changeset = Todos.change_category(%Category{user_id: socket.assigns.current_user_id})

        socket =
          socket
          |> assign(categories: updated_categories)
          |> assign(form: to_form(changeset))
          |> put_flash(:info, "Category created successfully")

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  def handle_info({:rate_updated, rate}, socket) do
    send_update(TodoListWeb.CryptoRateComponent, id: "crypto-rate", crypto_rate: to_string(rate))
    {:noreply, socket}
  end

  def handle_info(_, socket), do: {:noreply, socket}

  def render(assigns) do
    ~F"""
    <div class="container mx-auto p-6 bg-gray-100 rounded-lg shadow-lg">
      <h1 class="text-3xl font-bold mb-6 text-center text-gray-800">Task Categories</h1>

      <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
        <div class="bg-white p-4 rounded-md shadow">
          <h2 class="text-xl font-semibold mb-4 text-gray-700">Add New Category</h2>
          <CategoryForm on_submit="add_category" />
        </div>

        <div class="bg-white p-4 rounded-md shadow">
          <h2 class="text-xl font-semibold mb-4 text-gray-700">Category List</h2>
          <CategoryList categories={@categories} />
        </div>
      </div>

      <div class="mt-6 grid grid-cols-1 md:grid-cols-2 gap-6">
        <div class="bg-white p-4 rounded-md shadow">
          <CategoryCounter id="category_counter" count={length(@categories)} />
        </div>

        <div class="bg-white p-4 rounded-md shadow">
          <.live_component module={TodoListWeb.CryptoRateComponent} id="crypto-rate" />
        </div>
      </div>
    </div>
    """
  end
end
