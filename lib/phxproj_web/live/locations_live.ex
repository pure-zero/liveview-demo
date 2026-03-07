defmodule PhxprojWeb.LocationsLive do
  use PhxprojWeb, :live_view

  alias Phxproj.Locations

  @impl true
  def mount(_params, _session, socket) do
    locations = Locations.list_all()

    socket =
      socket
      |> assign(:page_title, "Locations")
      |> assign(:locations, locations)

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-900 text-white">
      <div class="mx-auto max-w-6xl p-4 sm:p-6">
        <div class="mb-8 text-center">
          <h1 class="text-4xl sm:text-5xl font-bold mb-4">
            <span class="text-amber-400">London</span> <span class="text-white">Locations</span>
          </h1>
          <p class="text-gray-300 text-lg mb-6">Choose your destination to begin your investigation</p>
          
          <div class="flex justify-center">
            <.link
              navigate={~p"/solution"}
              class="inline-flex items-center px-6 py-2 text-sm font-medium rounded-lg bg-gray-700 border border-amber-600 text-amber-400 hover:bg-gray-600 hover:border-amber-500 transition-all duration-200"
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
        "hover:bg-gray-750 hover:border-amber-500/50 transition-all duration-200",
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

      <div class="flex items-center text-amber-400 text-sm font-medium group">
        Enter location
        <.icon name="hero-arrow-right" class="w-4 h-4 ml-1 transition-transform group-hover:translate-x-1" />
      </div>
    </.link>
    """
  end
end