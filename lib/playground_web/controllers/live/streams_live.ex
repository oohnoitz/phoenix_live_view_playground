defmodule PlaygroundWeb.StreamsLive do
  use PlaygroundWeb, :live_view

  def render(assigns) do
    ~H"""
    <h1>Streams</h1>

    <div class="mt-4 space-y-4">
      <div>
        <h2 class="text-lg">Normal</h2>
        <ul id="stream-1" class="list-disc list-inside" phx-update="stream">
          <li :for={{dom_id, item} <- @streams.items_1} id={dom_id}>
            <%= item.id %>
          </li>
        </ul>
      </div>

      <div>
        <h2 class="text-lg">Live Component</h2>
        <ul id="stream-2" class="list-disc list-inside" phx-update="stream">
          <.live_component
            :for={{dom_id, item} <- @streams.items_2}
            module={PlaygroundWeb.StreamsResetComponent}
            id={dom_id}
            text={item.id}
          />
        </ul>
      </div>

      <div class="mt-2">
        <button class="bg-gray-100 px-3 py-1 text-sm border" phx-click="add">Add</button>
        <button class="bg-gray-100 px-3 py-1 text-sm border" phx-click="reset">Reset Outer</button>
      </div>

      <div>
        <h2 class="text-lg">Live View (Nested)</h2>
        <ul id="stream-3-nested" class="list-disc list-inside" phx-update="stream">
          <%= for {dom_id, _item} <- @streams.items_3 do %>
            <%= live_render(@socket, PlaygroundWeb.StreamsNestedLive, id: dom_id) %>
          <% end %>
        </ul>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:increment, 1)
      |> stream_configure(:items_1, dom_id: &"item-1-#{&1.id}")
      |> stream(:items_1, items())
      |> stream_configure(:items_2, dom_id: &"item-2-#{&1.id}")
      |> stream(:items_2, items())
      |> stream_configure(:items_3, dom_id: &"item-3-#{&1.id}")
      |> stream(:items_3, items())

    {:ok, socket}
  end

  def handle_event("reset", _params, socket) do
    socket =
      socket
      |> stream(:items_1, items(), reset: true)
      |> stream(:items_2, items(), reset: true)
      |> stream(:items_3, items(), reset: true)

    {:noreply, socket}
  end

  def handle_event("add", _params, socket) do
    socket =
      socket
      |> update(:increment, &(&1 + 1))
      |> then(&stream_insert(&1, :items_1, %{id: &1.assigns.increment}))
      |> then(&stream_insert(&1, :items_2, %{id: &1.assigns.increment}))
      |> then(&stream_insert(&1, :items_3, %{id: &1.assigns.increment}))

    {:noreply, socket}
  end

  defp items do
    [%{id: 1}]
  end
end
