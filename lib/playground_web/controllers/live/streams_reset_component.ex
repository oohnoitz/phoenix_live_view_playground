defmodule PlaygroundWeb.StreamsResetComponent do
  use PlaygroundWeb, :live_component

  def render(assigns) do
    ~H"""
    <li id={@id}>
      <%= @text %>
    </li>
    """
  end
end
