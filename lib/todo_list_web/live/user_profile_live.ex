defmodule TodoListWeb.UserProfileLive do
  use TodoListWeb, :live_view
  alias TodoList.Accounts

  def mount(_params, session, socket) do
    user_id = session["user_id"]
    user = Accounts.get_user!(user_id)
    changeset = Accounts.change_user(user)

    socket = socket
      |> assign(current_user: user, user: user, form: to_form(changeset))
      |> assign(picture_form: to_form(Accounts.change_user(user)))

    {:ok, socket}
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset =
      socket.assigns.user
      |> Accounts.change_user(user_params)
      |> Map.put(:action, :validate)

    case Accounts.update_user(socket.assigns.user, user_params) do
      {:ok, updated_user} ->
        socket = socket
          |> assign(user: updated_user, current_user: updated_user, form: to_form(changeset))
          |> push_event("user_updated", %{name: updated_user.name})
        {:noreply, socket}

      {:error, _changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  def handle_event("validate_picture", %{"user" => user_params}, socket) do
    changeset =
      socket.assigns.user
      |> Accounts.change_user(user_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, picture_form: to_form(changeset))}
  end

  def handle_event("save_picture", %{"user" => user_params}, socket) do
    case Accounts.update_user(socket.assigns.user, user_params) do
      {:ok, updated_user} ->
        socket = socket
          |> assign(user: updated_user, current_user: updated_user)
          |> assign(picture_form: to_form(Accounts.change_user(updated_user)))
          |> put_flash(:info, "Profile picture updated successfully")
          |> push_event("user_updated", %{name: updated_user.name, picture: updated_user.picture})
        {:noreply, socket}

      {:error, changeset} ->
        {:noreply, assign(socket, picture_form: to_form(changeset))}
    end
  end

  def render(assigns) do
    ~H"""
    <div class="max-w-2xl mx-auto">
      <.header>
        User Profile
        <:subtitle>Manage your account settings</:subtitle>
      </.header>

      <div class="mb-6">
        <img src={@user.picture} alt="User Profile Picture" class="w-32 h-32 rounded-full mx-auto mb-4" />
        <.simple_form
          for={@picture_form}
          id="picture-form"
          phx-change="validate_picture"
          phx-submit="save_picture"
        >
          <.input field={@picture_form[:picture]} type="url" label="Profile Picture URL" phx-debounce="300" />
          <:actions>
            <.button phx-disable-with="Saving...">Save Picture</.button>
          </:actions>
        </.simple_form>
      </div>

      <.simple_form
        for={@form}
        id="user-form"
        phx-change="validate"
      >
        <.input field={@form[:name]} type="text" label="Name" phx-debounce="300" />
        <.input field={@form[:email]} type="email" label="Email" disabled />
      </.simple_form>
    </div>
    """
  end
end
