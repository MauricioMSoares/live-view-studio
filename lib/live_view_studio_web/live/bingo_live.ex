defmodule LiveViewStudioWeb.BingoLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudioWeb.Presence

  @topic "users:bingo"

  def mount(_params, _session, socket) do
    %{current_user: current_user} = socket.assigns

    if connected?(socket) do
      Phoenix.PubSub.subscribe(LiveViewStudio.PubSub, @topic)

      {:ok, _} =
        Presence.track(self(), @topic, current_user.id, %{
          username: current_user.email |> String.split("@") |> hd(),
          timestamp: Timex.now() |> Timex.format!("%H:%M", :strftime)
        })

      :timer.send_interval(3000, self(), :tick)
    end

    presences = Presence.list(@topic)

    socket =
      socket
      |> assign(number: nil)
      |> assign(numbers: all_numbers())
      |> assign(:presences, simple_presence_map(presences))

    {:ok, socket}
  end

  def simple_presence_map(presences) do
    Enum.into(presences, %{}, fn {user_id, %{metas: [meta | _]}} ->
      {user_id, meta}
    end)
  end

  def render(assigns) do
    ~H"""
    <h1>Bingo Boss 📢</h1>
    <div id="bingo">
      <div class="users">
        <ul>
          <li :for={{_user_id, meta} <- @presences}>
            <span class="username">
              <%= meta.username %>
            </span>
            <span class="timestamp">
              <%= meta.timestamp %>
            </span>
          </li>
        </ul>
      </div>
      <div class="number">
        <%= @number %>
      </div>
    </div>
    """
  end

  # Assigns the next random bingo number, removing it
  # from the assigned list of numbers. Resets the list
  # when the last number has been picked.
  def pick(socket) do
    case socket.assigns.numbers do
      [head | []] ->
        assign(socket, number: head, numbers: all_numbers())

      [head | tail] ->
        assign(socket, number: head, numbers: tail)
    end
  end

  # Returns a list of all valid bingo numbers in random order.
  #
  # Example: ["B 4", "N 40", "O 73", "I 29", ...]
  def all_numbers() do
    ~w(B I N G O)
    |> Enum.zip(Enum.chunk_every(1..75, 15))
    |> Enum.flat_map(fn {letter, numbers} ->
      Enum.map(numbers, &"#{letter} #{&1}")
    end)
    |> Enum.shuffle()
  end

  def handle_info(:tick, socket) do
    {:noreply, pick(socket)}
  end

  def handle_info(%{event: "presence_diff", payload: diff}, socket) do
    socket =
      socket
      |> remove_presences(diff.leaves)
      |> add_presences(diff.joins)

    {:noreply, socket}
  end

  defp remove_presences(socket, leaves) do
    user_ids = Enum.map(leaves, fn {user_id, _} -> user_id end)

    presences = Map.drop(socket.assigns.presences, user_ids)

    assign(socket, :presences, presences)
  end

  defp add_presences(socket, joins) do
    presences = Map.merge(socket.assigns.presences, simple_presence_map(joins))
    assign(socket, :presences, presences)
  end
end
