defmodule PhxprojWeb.LocationChatLive do
  use PhxprojWeb, :live_view

  alias Phxproj.Locations
  alias Phxproj.OpenAIClient

  @impl true
  def mount(%{"location_id" => location_id}, _session, socket) do
    location = Locations.get_by_id(location_id)

    if location do
      # Set up timer for live server time updates (every 1 seconds for demo)
      if connected?(socket) do
        Process.send_after(self(), :update_time, 1_000)
      end

      socket =
        socket
        |> assign(:page_title, location.name)
        |> assign(:location, location)
        |> assign(:messages, [])
        |> assign(:message_form, to_form(%{"content" => ""}, as: :message))
        |> assign(:current_time, get_london_time())

      # Generate initial welcome message asynchronously
      send(self(), {:generate_welcome_message})

      {:ok, socket}
    else
      {:ok, push_navigate(socket, to: ~p"/locations")}
    end
  end

  @impl true
  def handle_event("send_message", %{"message" => %{"content" => content}}, socket) do
    content = String.trim(content)

    socket =
      if content != "" do
        user_message = %{
          id: System.unique_integer([:positive]),
          content: content,
          sender: :user,
          timestamp: DateTime.utc_now()
        }

        # Add user message immediately
        messages_with_user = socket.assigns.messages ++ [user_message]

        socket =
          socket
          |> assign(:messages, messages_with_user)
          |> assign(:message_form, to_form(%{"content" => ""}, as: :message))
          |> push_event("clear_message_input", %{})

        # Generate AI response asynchronously
        send(self(), {:generate_ai_response, content, messages_with_user})

        socket
      else
        socket
      end

    {:noreply, socket}
  end

  @impl true
  def handle_info({:generate_ai_response, user_content, current_messages}, socket) do
    conversation_history =
      current_messages
      |> Enum.filter(&(&1.sender != :user or &1.content != user_content))  # Exclude the current user message
      |> Enum.take(-10)  # Keep last 10 for context

    case OpenAIClient.generate_location_response(socket.assigns.location, user_content, conversation_history) do
      {:ok, ai_response} ->
        location_message = %{
          id: System.unique_integer([:positive]),
          content: ai_response,
          sender: :location,
          timestamp: DateTime.utc_now()
        }

        messages = current_messages ++ [location_message]
        {:noreply, assign(socket, :messages, messages)}

      {:error, _reason} ->
        # Fallback to static response if API fails
        fallback_response = generate_fallback_response(socket.assigns.location, user_content)

        location_message = %{
          id: System.unique_integer([:positive]),
          content: fallback_response,
          sender: :location,
          timestamp: DateTime.utc_now()
        }

        messages = current_messages ++ [location_message]

        socket =
          socket
          |> assign(:messages, messages)
          |> put_flash(:error, "AI service temporarily unavailable. Using fallback responses.")

        {:noreply, socket}
    end
  end

  @impl true
  def handle_info(:update_time, socket) do
    # Schedule the next update (every 1 seconds for demo)
    Process.send_after(self(), :update_time, 1_000)
    {:noreply, assign(socket, :current_time, get_london_time())}
  end

  @impl true
  def handle_info({:generate_welcome_message}, socket) do
    welcome_prompt = "Sherlock Holmes has just entered your location. Greet him by name, warmly and with familiarity. Keep it brief - 1-2 sentences."

    case OpenAIClient.generate_location_response(socket.assigns.location, welcome_prompt, []) do
      {:ok, welcome_message} ->
        location_message = %{
          id: 1,
          content: welcome_message,
          sender: :location,
          timestamp: DateTime.utc_now()
        }

        {:noreply, assign(socket, :messages, [location_message])}

      {:error, _reason} ->
        # Fallback welcome message
        fallback_welcome = get_fallback_welcome(socket.assigns.location)

        location_message = %{
          id: 1,
          content: fallback_welcome,
          sender: :location,
          timestamp: DateTime.utc_now()
        }

        {:noreply, assign(socket, :messages, [location_message])}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="min-h-screen bg-black text-white">
        <div class="mx-auto max-w-4xl p-4 sm:p-6">
          <div class="mb-6">
            <div class="flex items-center justify-between mb-4">
              <div class="flex items-center space-x-4">
                <.link
                  navigate={~p"/locations"}
                  class="theme-purple-primary theme-purple-primary-hover flex items-center text-sm font-medium transition-colors"
                >
                  <.icon name="hero-arrow-left" class="w-4 h-4 mr-1" />
                  Back to Locations
                </.link>
              </div>

              <!-- Live server time display -->
              <div class="bg-gray-800 px-3 py-1 rounded border border-gray-700">
                <span class="text-xs text-gray-300 font-mono">
                  🕒 {@current_time}
                </span>
              </div>
            </div>

            <div class="bg-gray-800 rounded-lg border border-gray-700 p-4 sm:p-6 mb-6 shadow-xl">
              <div>
                <h1 class="text-2xl sm:text-3xl font-bold text-white mb-2">{@location.name}</h1>
                <p class="text-gray-300 mb-3 text-sm sm:text-base">{@location.description}</p>
              </div>
            </div>
          </div>

          <div class="bg-gray-800 rounded-lg border border-gray-700 flex flex-col h-96 sm:h-[500px] shadow-xl">
          <div class="flex-1 overflow-y-auto p-3 sm:p-4 space-y-3 sm:space-y-4" id="chat-messages" phx-hook="ScrollToBottom">
            <div :for={message <- @messages} class={[
              "flex",
              if(message.sender == :user, do: "justify-end", else: "justify-start")
            ]}>
              <div class={[
                "max-w-xs sm:max-w-sm lg:max-w-md px-3 sm:px-4 py-2 rounded-lg text-sm break-words",
                if(message.sender == :user,
                  do: "theme-primary-bg text-white font-medium",
                  else: "bg-gray-700 text-gray-100 border border-gray-600")
              ]}>
                <p class="break-words">{message.content}</p>
                <p class={[
                  "text-xs mt-1",
                  if(message.sender == :user, do: "text-purple-900/70", else: "text-gray-400")
                ]}>
                  {format_time(message.timestamp)}
                </p>
              </div>
            </div>
          </div>

          <div class="border-t border-gray-700 p-4 sm:p-6">
            <.form
              for={@message_form}
              id="message-form"
              phx-submit="send_message"
              phx-hook="ClearOnSubmit"
              class="w-full flex space-x-3"
            >
              <div class="flex-1 min-w-0">
                <.input
                  field={@message_form[:content]}
                  type="text"
                  placeholder="Type your message..."
                  class="w-full bg-gray-700 border-gray-600 text-white placeholder-gray-400 theme-purple-focus rounded-lg text-base py-3 px-4 min-h-[48px]"
                  autocomplete="off"
                />
              </div>
              <button
                type="submit"
                class="inline-flex items-center justify-center px-4 sm:px-6 py-3 border border-transparent text-base font-medium rounded-lg shadow-sm text-white theme-purple-bg theme-purple-bg-hover focus:outline-none focus:ring-2 focus:ring-offset-2 theme-purple-ring focus:ring-offset-gray-800 transition-colors min-w-[48px] min-h-[48px] shrink-0"
              >
                <.icon name="hero-paper-airplane" class="w-5 h-5" />
              </button>
            </.form>
          </div>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  defp get_fallback_welcome(location) do
    clue = case Phxproj.CaseData.get_clues_for_location(location.id) do
      [c | _] -> " And since you're here — #{c.text}"
      [] -> ""
    end

    base = case location.id do
      "baker-street" -> "Welcome to 221B Baker Street!"
      "chemist" -> "Welcome to the chemist!"
      "bank" -> "Good day, welcome to the bank."
      "carriage-depot" -> "Welcome to the carriage depot!"
      "docks" -> "Ahoy! Welcome to the docks."
      "hotel" -> "Welcome to our grand hotel!"
      "locksmith" -> "Welcome to the locksmith!"
      "museum" -> "Welcome to the museum!"
      "newsagents" -> "Welcome to the newsagent's!"
      "park" -> "Welcome to the park!"
      "pawnbroker" -> "Welcome to the pawnbroker!"
      "theater" -> "Welcome to the theater!"
      "boars-head" -> "Welcome to the Boar's Head!"
      "tobacconist" -> "Welcome to the tobacco shop!"
      "scotland-yard" -> "Welcome to Scotland Yard!"
      _ -> "Welcome!"
    end

    base <> clue
  end

  defp generate_fallback_response(location, _user_message) do
    case Phxproj.CaseData.get_clues_for_location(location.id) do
      [clue | _] -> clue.text
      [] -> "I'm afraid I don't know much that would help you with that."
    end
  end

  defp format_time(datetime) do
    datetime
    |> DateTime.to_time()
    |> Time.to_string()
    |> String.slice(0, 5)
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
