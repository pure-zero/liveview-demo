defmodule PhxprojWeb.Rain do
  import Phoenix.LiveView
  import Phoenix.Component

  def on_mount(:default, _params, _session, socket) do
    if connected?(socket) do
      send(self(), :init_rain)
    end

    socket =
      socket
      |> assign(:rain_droplets, [])
      |> attach_hook(:rain, :handle_info, &handle_rain_info/2)

    {:cont, socket}
  end

  defp handle_rain_info(:init_rain, socket) do
    droplets = generate_rain_droplets(100)
    Process.send_after(self(), :update_rain, 100)

    {:halt,
     socket
     |> assign(:rain_droplets, droplets)
     |> push_event("rain_update", %{droplets: droplets})}
  end

  defp handle_rain_info(:update_rain, socket) do
    # new_droplets = generate_rain_droplets(:rand.uniform() * 10 + 3|> round())
    new_droplets = generate_rain_droplets(5)
    Process.send_after(self(), :update_rain, 100)
    {:halt, push_event(socket, "rain_new_droplets", %{droplets: new_droplets})}
  end

  defp handle_rain_info(_other, socket), do: {:cont, socket}

  defp generate_rain_droplets(count) do
    for _ <- 1..count do
      %{
        id: :crypto.strong_rand_bytes(8) |> Base.encode64(),
        x: :rand.uniform() * 100,
        y: :rand.uniform() * 100,
        opacity: :rand.uniform(),
        animation_duration: :rand.uniform() * 2 + 1,
        delay: :rand.uniform() * 3,
        scale: :rand.uniform() * 0.8 + 0.2,
        speed: :rand.uniform() * 0.5 + 0.5
      }
    end
  end
end
