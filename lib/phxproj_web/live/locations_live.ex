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
    <div class="mx-auto max-w-4xl p-6">
      <div class="mb-8">
        <h1 class="text-4xl font-bold text-gray-900 mb-2">London Locations</h1>
        <p class="text-gray-600">Click on any location to enter and start a conversation</p>
      </div>

      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <.location_card 
          :for={location <- @locations} 
          location={location} 
        />
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
        "block p-6 bg-white rounded-lg border border-gray-200 shadow-sm",
        "hover:shadow-md hover:border-gray-300 transition-all duration-200",
        "transform hover:-translate-y-1"
      ]}
    >
      <div class="flex items-start justify-between mb-3">
        <h3 class="text-xl font-semibold text-gray-900 line-clamp-2">
          {@location.name}
        </h3>
        <%= if not @location.can_be_sealed do %>
          <span class="flex-shrink-0 inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-blue-100 text-blue-800 ml-2">
            Protected
          </span>
        <% end %>
      </div>

      <p class="text-gray-600 text-sm mb-3 line-clamp-2">
        {@location.description}
      </p>

      <%= if @location.special_rules do %>
        <div class="border-t border-gray-100 pt-3">
          <p class="text-xs text-amber-700 bg-amber-50 px-2 py-1 rounded">
            <.icon name="hero-exclamation-triangle" class="w-3 h-3 inline mr-1" />
            {@location.special_rules}
          </p>
        </div>
      <% end %>

      <div class="mt-4 flex items-center text-indigo-600 text-sm font-medium">
        Enter location
        <.icon name="hero-arrow-right" class="w-4 h-4 ml-1" />
      </div>
    </.link>
    """
  end
end