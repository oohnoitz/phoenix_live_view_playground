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

      <div>
        <h2 class="text-lg">Limit (0, -5)</h2>
        <ul id="stream-3" class="list-disc list-inside" phx-update="stream">
          <li :for={{dom_id, item} <- @streams.items_3} id={dom_id}>
            <%= item.id %>
          </li>
        </ul>
      </div>

      <div>
        <h2 class="text-lg">Limit (-1, 5)</h2>
        <ul id="stream-4" class="list-disc list-inside" phx-update="stream">
          <li :for={{dom_id, item} <- @streams.items_4} id={dom_id}>
            <%= item.id %>
          </li>
        </ul>
      </div>

      <div>
        <h2 class="text-lg">Limit (0, -5)</h2>
        <ul id="stream-5" class="list-disc list-inside" phx-update="stream">
          <li :for={{dom_id, item} <- @streams.items_5} id={dom_id}>
            <%= item.id %>
          </li>
        </ul>
      </div>

      <div>
        <h2 class="text-lg">Limit (-1, 5)</h2>
        <ul id="stream-6" class="list-disc list-inside" phx-update="stream">
          <li :for={{dom_id, item} <- @streams.items_6} id={dom_id}>
            <%= item.id %>
          </li>
        </ul>
      </div>

      <div class="mt-2">
        <button class="bg-gray-100 px-3 py-1 text-sm border" phx-click="add">Add</button>
        <button class="bg-gray-100 px-3 py-1 text-sm border" phx-click="add5">Add 5</button>
        <button class="bg-gray-100 px-3 py-1 text-sm border" phx-click="add10">Add 10</button>
        <button class="bg-gray-100 px-3 py-1 text-sm border" phx-click="reset">Reset</button>
      </div>

      <div>
        <h2 class="text-lg">Live View (Nested)</h2>
        <ul id="stream-7-nested" class="list-disc list-inside" phx-update="stream">
          <%= for {dom_id, _item} <- @streams.items_7 do %>
            <%= live_render(@socket, PlaygroundWeb.StreamsNestedLive,
              id: dom_id,
              session: %{"nested_id" => dom_id}
            ) %>
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
      |> stream(:items_3, items(), limit: 5)
      |> stream_configure(:items_4, dom_id: &"item-4-#{&1.id}")
      |> stream(:items_4, items())
      |> stream_configure(:items_5, dom_id: &"item-5-#{&1.id}")
      |> stream(:items_5, items())
      |> stream_configure(:items_6, dom_id: &"item-6-#{&1.id}")
      |> stream(:items_6, items())
      |> stream_configure(:items_7, dom_id: &"item-7-#{&1.id}")
      |> stream(:items_7, items())

    {:ok, socket}
  end

  def handle_event("reset", _params, socket) do
    socket =
      socket
      |> stream(:items_1, items(), reset: true)
      |> stream(:items_2, items(), reset: true)
      |> stream(:items_3, items(), reset: true)
      |> stream(:items_4, items(), reset: true)
      |> stream(:items_5, items(), reset: true)
      |> stream(:items_6, items(), reset: true)
      |> stream(:items_7, items(), reset: true)

    {:noreply, socket}
  end

  def handle_event("add", _params, socket) do
    socket =
      socket
      |> update(:increment, &(&1 + 1))
      |> then(&stream_insert(&1, :items_1, %{id: &1.assigns.increment}))
      |> then(&stream_insert(&1, :items_2, %{id: &1.assigns.increment}))
      |> then(&stream_insert(&1, :items_3, %{id: &1.assigns.increment}, at: 0, limit: 5))
      |> then(&stream_insert(&1, :items_4, %{id: &1.assigns.increment}, at: -1, limit: -5))
      |> then(&stream_insert(&1, :items_5, %{id: &1.assigns.increment}, at: 0, limit: 5))
      |> then(&stream_insert(&1, :items_6, %{id: &1.assigns.increment}, at: -1, limit: -5))
      |> then(&stream_insert(&1, :items_7, %{id: &1.assigns.increment}))

    {:noreply, socket}
  end

  def handle_event("add5", _params, socket) do
    socket =
      socket
      |> then(&stream(&1, :items_1, bulk5(&1.assigns.increment)))
      |> then(&stream(&1, :items_2, bulk5(&1.assigns.increment)))
      |> then(&stream(&1, :items_3, bulk5(&1.assigns.increment), at: 0, limit: 5))
      |> then(&stream(&1, :items_4, bulk5(&1.assigns.increment), at: -1, limit: -5))
      |> then(&stream(&1, :items_5, bulk5(&1.assigns.increment), at: 0, limit: 5))
      |> then(&stream(&1, :items_6, bulk5(&1.assigns.increment), at: -1, limit: -5))
      |> then(&stream(&1, :items_7, bulk5(&1.assigns.increment)))
      |> update(:increment, &(&1 + 5))

    {:noreply, socket}
  end

  def handle_event("add10", _params, socket) do
    socket =
      socket
      |> then(&stream(&1, :items_1, bulk10(&1.assigns.increment)))
      |> then(&stream(&1, :items_2, bulk10(&1.assigns.increment)))
      |> then(&stream(&1, :items_3, bulk10(&1.assigns.increment), at: 0, limit: 5))
      |> then(&stream(&1, :items_4, bulk10(&1.assigns.increment), at: -1, limit: -5))
      |> then(&stream(&1, :items_5, bulk10(&1.assigns.increment), at: 0, limit: 5))
      |> then(&stream(&1, :items_6, bulk10(&1.assigns.increment), at: -1, limit: -5))
      |> then(&stream(&1, :items_7, bulk10(&1.assigns.increment)))
      |> update(:increment, &(&1 + 10))

    {:noreply, socket}
  end

  defp items do
    [%{id: 1}]
  end

  defp bulk5(inc) do
    [
      %{id: inc + 1},
      %{id: inc + 2},
      %{id: inc + 3},
      %{id: inc + 4},
      %{id: inc + 5}
    ]
  end

  defp bulk10(inc) do
    [
      %{id: inc + 1},
      %{id: inc + 2},
      %{id: inc + 3},
      %{id: inc + 4},
      %{id: inc + 5},
      %{id: inc + 6},
      %{id: inc + 7},
      %{id: inc + 8},
      %{id: inc + 9},
      %{id: inc + 10}
    ]
  end
end
