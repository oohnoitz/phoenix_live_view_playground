defmodule PlaygroundWeb.StreamsLive do
  use PlaygroundWeb, :live_view

  def render(assigns) do
    ~H"""
    <h1>Streams</h1>

    <div class="mt-4 space-y-4">
      <div>
        <h2>Normal Elements</h2>
        <ul id="stream-1" class="list-disc list-inside" phx-update="stream">
          <li :for={{dom_id, item} <- @streams.items_1} id={dom_id}>
            <%= item.text %>
          </li>
        </ul>
      </div>

      <div>
        <h2>Live Component</h2>
        <ul id="stream-2" class="list-disc list-inside" phx-update="stream">
          <.live_component
            :for={{dom_id, item} <- @streams.items_2}
            module={PlaygroundWeb.StreamsResetComponent}
            id={dom_id}
            text={item.text}
          />
        </ul>
      </div>

      <div class="mt-2">
        <button class="bg-gray-100 px-3 py-1 text-sm border" phx-click="reset">Reset</button>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    socket =
      socket
      |> stream_configure(:items_1, dom_id: &"item-1-#{&1.id}")
      |> stream(:items_1, items())
      |> stream_configure(:items_2, dom_id: &"item-2-#{&1.id}")
      |> stream(:items_2, items())

    {:ok, socket}
  end

  def handle_event("reset", _params, socket) do
    socket =
      socket
      |> stream(:items_1, items(), reset: true)
      |> stream(:items_2, items(), reset: true)

    {:noreply, socket}
  end

  defp items do
    [%{id: 1, text: "HEY"}]
  end
end
