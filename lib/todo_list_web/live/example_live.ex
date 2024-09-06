defmodule MyAppWeb.ExampleLive do
  use Surface.LiveView

  alias MyAppWeb.Components.ExampleComponent

  def render(assigns) do
    ~F"""
    <ExampleComponent>
      Hi there!
    </ExampleComponent>
    """
  end
end
