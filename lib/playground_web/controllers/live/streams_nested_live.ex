defmodule PlaygroundWeb.StreamsNestedLive do
  use PlaygroundWeb, :live_view

  def render(assigns) do
    ~H"""
    <div>
      <ul id={"nested-#{@id}"} class="list-disc list-inside" phx-update="stream">
        <li :for={{dom_id, item} <- @streams.nested_items} id={dom_id}>
          <%= item.id %>
        </li>
      </ul>

      <div class="mt-2">
        <button class="bg-gray-100 px-3 py-1 text-sm border" phx-click="add">Add</button>
        <button class="bg-gray-100 px-3 py-1 text-sm border" phx-click="reset">Reset</button>
      </div>
    </div>
    """
  end

  def mount(_params, session, socket) do
    socket =
      socket
      |> assign(:id, Map.get(session, "nested_id"))
      |> assign(:increment, 1)
      |> stream_configure(:nested_items,
        dom_id: &"nested-item-#{Map.get(session, "nested_id")}-#{&1.id}"
      )
      |> stream(:nested_items, items())

    {:ok, socket}
  end

  def handle_event("add", _params, socket) do
    socket =
      socket
      |> update(:increment, &(&1 + 1))
      |> then(&stream_insert(&1, :nested_items, %{id: &1.assigns.increment}))

    {:noreply, socket}
  end

  defp items do
    [%{id: 1}]
  end
end
