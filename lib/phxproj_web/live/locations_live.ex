defmodule PhxprojWeb.LocationsLive do
  use PhxprojWeb, :live_view

  alias Phxproj.Locations

  @impl true
  def mount(_params, _session, socket) do
    locations = Locations.list_all()

    # Set up timer for live server time updates (every 1 seconds for demo)
    if connected?(socket) do
      Process.send_after(self(), :update_time, 1_000)
    end

    socket =
      socket
      |> assign(:page_title, "Locations")
      |> assign(:locations, locations)
      |> assign(:current_time, get_london_time())

    {:ok, socket}
  end

  @impl true
  def handle_info(:update_time, socket) do
    # Schedule the next update (every 2 seconds for demo)
    Process.send_after(self(), :update_time, 1_000)
    {:noreply, assign(socket, :current_time, get_london_time())}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div id="rain" phx-hook="RainEffect" phx-update="ignore" class="fixed inset-0 pointer-events-none z-2"></div>
    <div class="min-h-screen bg-black text-white">
      <div class="mx-auto max-w-6xl p-4 sm:p-6">
        <div class="mb-8 text-center">
          <div class="mb-4 flex justify-start">
            <.link
              navigate={~p"/"}
              class="theme-purple-primary theme-purple-primary-hover flex items-center text-sm font-medium transition-colors"
            >
              <.icon name="hero-arrow-left" class="w-4 h-4 mr-1" />
              Back to Case File
            </.link>
          </div>

          <!-- Live server time display -->
          <div class="mb-4 flex justify-center">
            <div class="bg-gray-800 px-4 py-2 rounded-lg border border-gray-700">
              <span class="text-sm text-gray-300 font-mono">
                🕒 Server Time: {@current_time}
              </span>
            </div>
          </div>

          <h1 class="text-4xl sm:text-5xl font-bold mb-4">
            <span class="theme-purple-primary">London</span> <span class="text-white">Locations</span>
          </h1>
          <p class="text-gray-300 text-lg mb-6">Choose your destination to begin your investigation</p>

          <div class="flex justify-center">
            <.link
              navigate={~p"/solution"}
              class="inline-flex items-center px-6 py-2 text-sm font-medium rounded-lg bg-gray-700 theme-purple-border theme-purple-primary hover:bg-gray-600 theme-purple-border-hover transition-all duration-200"
            >
              <.icon name="hero-document-text" class="w-4 h-4 mr-2" />
              Ready to Submit Your Solution?
            </.link>
          </div>
        </div>

        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4 sm:gap-6">
          <.location_card
            :for={location <- @locations}
            location={location}
          />
        </div>
      </div>
    </div>
    """
  end

  attr :location, Phxproj.Locations, required: true

  def location_card(assigns) do
    ~H"""
    <.link
      navigate={~p"/locations/#{@location.id}"}
      class={[
        "block p-4 sm:p-6 bg-gray-800 rounded-lg border border-gray-700 shadow-lg",
        "hover:bg-gray-750 hover:border-purple-500/50 transition-all duration-200",
        "transform hover:-translate-y-1 hover:shadow-xl",
        "backdrop-blur-sm bg-gray-800/90"
      ]}
    >
      <div class="mb-3">
        <h3 class="text-lg sm:text-xl font-semibold text-white line-clamp-2">
          {@location.name}
        </h3>
      </div>

      <p class="text-gray-300 text-sm mb-4 line-clamp-3">
        {@location.description}
      </p>

      <div class="flex items-center theme-purple-primary text-sm font-medium group">
        Enter location
        <.icon name="hero-arrow-right" class="w-4 h-4 ml-1 transition-transform group-hover:translate-x-1" />
      </div>
    </.link>
    """
  end

  defp get_london_time do
    utc_now = DateTime.utc_now()
    # Simple offset for London (GMT+0 in winter, GMT+1 in summer)
    london_offset = if is_dst?(utc_now), do: 1, else: 0

    utc_now
    |> DateTime.add(london_offset * 3600, :second)
    |> Calendar.strftime("%H:%M:%S UTC#{if london_offset > 0, do: "+1", else: ""}")
  end

  # Simple DST check for UK (last Sunday in March to last Sunday in October)
  defp is_dst?(datetime) do
    month = datetime.month
    month >= 4 && month <= 9  # Approximate DST period
  end
end
