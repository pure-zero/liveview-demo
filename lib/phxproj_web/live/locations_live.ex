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
          <p class="text-gray-300 text-lg">Choose your destination to begin your investigation</p>
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
      <div class="flex items-start justify-between mb-3">
        <h3 class="text-lg sm:text-xl font-semibold text-white line-clamp-2">
          {@location.name}
        </h3>
        <%= if not @location.can_be_sealed do %>
          <span class="flex-shrink-0 inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-blue-900/50 text-blue-300 ml-2 border border-blue-700">
            Protected
          </span>
        <% end %>
      </div>

      <p class="text-gray-300 text-sm mb-3 line-clamp-3">
        {@location.description}
      </p>

      <%= if @location.special_rules do %>
        <div class="border-t border-gray-700 pt-3 mb-3">
          <p class="text-xs text-amber-300 bg-amber-900/30 px-2 py-1 rounded border border-amber-700/50">
            <.icon name="hero-exclamation-triangle" class="w-3 h-3 inline mr-1" />
            {@location.special_rules}
          </p>
        </div>
      <% end %>

      <div class="mt-4 flex items-center text-amber-400 text-sm font-medium group">
        Enter location
        <.icon name="hero-arrow-right" class="w-4 h-4 ml-1 transition-transform group-hover:translate-x-1" />
      </div>
    </.link>
    """
  end
end