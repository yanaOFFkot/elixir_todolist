defmodule TodoListWeb.Components.CategoryList do
  use Surface.Component

  prop categories, :list, required: true

  def render(assigns) do
    ~F"""
    <div>
      <h2 class="text-xl font-semibold mb-2">Categories</h2>
      <ul class="list-disc pl-5">
        {#for category <- @categories}
          <li>{category.name}</li>
        {/for}
      </ul>
    </div>
    """
  end
end
