defmodule TodoListWeb.Components.CategoryForm do
  use Surface.Component

  prop on_submit, :event
  prop name, :string, default: ""
  prop redirect_url, :string, required: true

  def render(assigns) do
    ~F"""
    <div>
      <h2 class="text-xl font-semibold mb-2">Add New Category</h2>
      <form :on-submit={@on_submit}>
        <div class="flex">
          <input
            type="text"
            class="flex-grow p-2 border rounded-l"
            placeholder="Category name"
            name="category[name]"
            value={@name}
          />
          <button type="submit" class="bg-blue-500 text-white p-2 rounded-r">
            Add
          </button>
        </div>
      </form>

      <div class="mt-4">
        <.link href={@redirect_url} class="text-blue-500">Back to Task</.link>
      </div>
    </div>
    """
  end
end
