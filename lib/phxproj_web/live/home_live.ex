defmodule PhxprojWeb.HomeLive do
  use PhxprojWeb, :live_view

  alias Phxproj.CaseData

  @impl true
  def mount(_params, _session, socket) do
    # Set up timer for live server time updates (every 5 seconds for demo)
    if connected?(socket) do
      Process.send_after(self(), :update_time, 5_000)
    end

    active_case = CaseData.get_active_case()

    socket =
      socket
      |> assign(:page_title, "221B Baker Street")
      |> assign(:case, active_case)
      |> assign(:current_time, get_london_time())

    {:ok, socket}
  end

  @impl true
  def handle_info(:update_time, socket) do
    # Schedule the next update (every 5 seconds for demo)
    Process.send_after(self(), :update_time, 5_000)
    {:noreply, assign(socket, :current_time, get_london_time())}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <!-- Background overlay -->
      <div class="fixed inset-0 bg-black bg-opacity-40 pointer-events-none z-1"></div>

      <div class="relative z-10 px-4 py-16 sm:px-6 lg:px-8">
        <div class="mx-auto max-w-4xl text-center">
          <!-- Title -->
          <h1 class="text-5xl sm:text-7xl font-bold tracking-tight mb-8">
            <span class="theme-purple-primary">221B</span>
            <span class="text-white">Baker Street</span>
          </h1>

          <!-- Story content -->
          <%= if @case do %>
            <div class="mx-auto max-w-3xl text-left bg-gray-800/50 backdrop-blur-sm rounded-lg p-8 shadow-2xl border border-gray-700">
              <h2 class="text-2xl font-bold mb-6 theme-purple-primary text-center">
                {@case.title}
              </h2>

              <div class="space-y-4 text-gray-300 leading-relaxed text-base sm:text-lg">
                <div class="whitespace-pre-wrap leading-7">{String.trim(@case.story)}</div>
              </div>
            </div>
          <% else %>
            <div class="mx-auto max-w-3xl text-center bg-gray-800/50 backdrop-blur-sm rounded-lg p-8 shadow-2xl border border-gray-700">
              <h2 class="text-2xl font-bold mb-6 theme-purple-primary">
                No Active Case
              </h2>
              <p class="text-gray-300">
                There are currently no active mystery cases available. Check back later!
              </p>
            </div>
          <% end %>

          <!-- Action buttons -->
          <div class="mt-12 flex flex-col sm:flex-row gap-4 justify-center">
            <a
              href={~p"/locations"}
              class="inline-flex items-center px-8 py-4 text-lg font-semibold rounded-lg theme-purple-gradient text-white theme-purple-gradient-hover transition-all duration-200 shadow-lg hover:shadow-xl transform hover:-translate-y-1"
            >
              <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" />
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" />
              </svg>
              Begin Your Investigation
            </a>

            <a
              href={~p"/solution"}
              class="inline-flex items-center px-8 py-4 text-lg font-semibold rounded-lg bg-gray-700 theme-purple-border theme-purple-primary hover:bg-gray-600 theme-purple-border-hover transition-all duration-200 shadow-lg hover:shadow-xl transform hover:-translate-y-1"
            >
              <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
              </svg>
              Submit Your Solution
            </a>
          </div>
        </div>
      </div>
    </Layouts.app>
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
