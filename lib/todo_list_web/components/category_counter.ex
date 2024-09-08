defmodule TodoListWeb.Components.CategoryCounter do
  use Surface.LiveComponent

  prop count, :integer, required: true

  def render(assigns) do
    ~F"""
    <div class="text-gray-600">
      Total categories: {@count}
    </div>
    """
  end
end
