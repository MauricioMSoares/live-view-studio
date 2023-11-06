defmodule LiveViewStudioWeb.ServerFormComponent do
  use LiveViewStudioWeb, :live_component

  alias LiveViewStudio.Servers
  alias LiveViewStudio.Servers.Server

  def mount(socket) do
    changeset = Servers.change_server(%Server{})

    {:ok, assign(socket, :form, to_form(changeset))}
  end

  def render(assigns) do
    ~H"""
    <div>
      <.form
        for={@form}
        phx-submit="save"
        phx-change="validate"
        phx-target={@myself}
      >
        <div class="field">
          <.input
            field={@form[:name]}
            placeholder="Name"
            autocomplete="off"
            phx-debounce="blur"
          />
        </div>
        <div class="field">
          <.input
            field={@form[:framework]}
            placeholder="Framework"
            autocomplete="off"
            phx-debounce="blur"
          />
        </div>
        <div class="field">
          <.input
            field={@form[:size]}
            type="number"
            placeholder="Size (MB)"
            autocomplete="off"
            phx-debounce="blur"
          />
        </div>
        <.button phx-disable-with="Saving...">
          Save
        </.button>
        <.link patch={~p"/servers"} class="cancel">
          Cancel
        </.link>
      </.form>
    </div>
    """
  end

  def handle_event("validate", %{"server" => server_params}, socket) do
    changeset =
      %Server{}
      |> Servers.change_server(server_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("drink", _, socket) do
    {:noreply, update(socket, :coffees, &(&1 + 1))}
  end

  def handle_event("save", %{"server" => server_params}, socket) do
    case Servers.create_server(server_params) do
      {:ok, server} ->
        send(self(), {__MODULE__, :server_created, server})
        {:noreply, socket}

      {:error, changeset} ->
        socket = put_flash(socket, :error, "Something went wrong.")
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
