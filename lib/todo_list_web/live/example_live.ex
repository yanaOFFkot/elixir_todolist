defmodule TodoListWeb.ExampleLive do
  use Surface.LiveView

  alias TodoListWeb.Components.ExampleComponent

  def render(assigns) do
    ~F"""
    <ExampleComponent>
      Hi there!
    </ExampleComponent>
    """
  end
end
