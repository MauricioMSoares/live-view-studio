defmodule LiveViewStudioWeb.LightLive do
  use LiveViewStudioWeb, :live_view

  def mount(_params, _session, socket) do
    socket = assign(socket, brightness: 10, temp: "3000")
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>Front Porch Light</h1>
    <div id="light" phx-window-keyup="click-update">
      <div class="meter">
        <span style={"width: #{@brightness}%; background: #{temp_color(@temp)}"}>
          <%= @brightness %>%
        </span>
      </div>
      <button phx-click="off">
        <img src="/images/light-off.svg" />
      </button>
      <button phx-click="down">
        <img src="/images/down.svg" />
      </button>
      <button phx-click="fire">
        <img src="/images/fire.svg" />
      </button>
      <button phx-click="up">
        <img src="/images/up.svg" />
      </button>
      <button phx-click="on">
        <img src="/images/light-on.svg" />
      </button>
    </div>
    <form style="margin-top: 24px" phx-change="update">
      <input
        type="range"
        min="0"
        max="100"
        name="brightness"
        value={@brightness}
        phx-debounce="250"
      />
    </form>
    <form phx-change="change-temp">
      <div
        style="display: flex; flex-direction: column; align-items: center"
        class="temps"
      >
        <%= for temp <- ["3000", "4000", "5000"] do %>
          <div>
            <input
              type="radio"
              id={temp}
              name="temp"
              value={temp}
              checked={temp == @temp}
            />
            <label for={temp}><%= temp %></label>
          </div>
        <% end %>
      </div>
    </form>
    """
  end

  def handle_event("click-update", %{"key" => "ArrowRight"}, socket) do
    socket = update(socket, :brightness, &min(&1 + 1, 100))
    {:noreply, socket}
  end

  def handle_event("click-update", %{"key" => "ArrowLeft"}, socket) do
    socket = update(socket, :brightness, &max(&1 - 1, 0))
    {:noreply, socket}
  end

  def handle_event("click-update", _, socket) do
    {:noreply, socket}
  end

  def handle_event("on", _, socket) do
    socket = assign(socket, brightness: 100)
    {:noreply, socket}
  end

  def handle_event("up", _, socket) do
    socket = update(socket, :brightness, &min(&1 + 10, 100))
    {:noreply, socket}
  end

  def handle_event("down", _, socket) do
    socket = update(socket, :brightness, &max(&1 - 10, 0))
    {:noreply, socket}
  end

  def handle_event("off", _, socket) do
    socket = assign(socket, brightness: 0)
    {:noreply, socket}
  end

  def handle_event("fire", _, socket) do
    socket = assign(socket, brightness: Enum.random(0..100))
    {:noreply, socket}
  end

  def handle_event("update", %{"brightness" => brightness}, socket) do
    {:noreply, assign(socket, brightness: brightness |> String.to_integer())}
  end

  def handle_event("change-temp", %{"temp" => temp}, socket) do
    socket = assign(socket, temp: temp)
    {:noreply, socket}
  end

  defp temp_color("3000"), do: "#F1C40D"
  defp temp_color("4000"), do: "#FEFF66"
  defp temp_color("5000"), do: "#99CCFF"
end
