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
    welcome_prompt = "Someone just entered your location. Greet them warmly and offer help. Keep it brief - 1-2 sentences."

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
          <div class="flex-1 overflow-y-auto p-3 sm:p-4 space-y-3 sm:space-y-4" id="chat-messages">
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
              class="w-full flex space-x-3"
            >
              <.input
                field={@message_form[:content]}
                type="text"
                placeholder="Type your message..."
                class="w-full flex-1 bg-gray-700 border-gray-600 text-white placeholder-gray-400 theme-purple-focus rounded-lg text-base py-3 px-4 min-h-[48px]"
                autocomplete="off"
              />
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
    case location.id do
      "baker-street" -> "Welcome to 221B Baker Street! This is where your adventure begins and ends."
      "chemist" -> "Welcome to the chemist! I have various potions and remedies. How can I help you?"
      "bank" -> "Good day! Welcome to the bank. How may I assist you with your financial needs?"
      "carriage-depot" -> "Welcome to the carriage depot! Need transportation around the city?"
      "docks" -> "Ahoy! Welcome to the busy docks. The ships come and go at all hours."
      "hotel" -> "Welcome to our grand hotel! Are you looking for accommodation or information?"
      "locksmith" -> "Welcome to the locksmith! I can provide you with new keys when needed."
      "museum" -> "Welcome to the museum! We have fascinating exhibits and artifacts."
      "newsagents" -> "Welcome to the newsagent's! Fresh newspapers and the latest gossip!"
      "park" -> "Welcome to the peaceful park! A lovely place for a stroll and conversation."
      "pawnbroker" -> "Welcome to the pawnbroker! I deal in valuable items and curiosities."
      "theater" -> "Welcome to the theater! The show must go on! What brings you here?"
      "boars-head" -> "Welcome to the Boar's Head! Pull up a chair and have a drink!"
      "tobacconist" -> "Welcome to the tobacco shop! Fine pipes and premium tobacco available."
      "scotland-yard" -> "Welcome to Scotland Yard! Justice never sleeps. How can we assist you?"
      _ -> "Welcome! How can I help you today?"
    end
  end

  defp generate_fallback_response(location, _user_message) do
    base_responses = [
      "Interesting... tell me more about that.",
      "I see. That's quite intriguing.",
      "Hmm, that reminds me of something...",
      "That's fascinating! What else can you tell me?",
      "I've heard whispers about such things around here.",
      "How curious! That's not something you hear every day."
    ]

    location_specific_responses = case location.id do
      "baker-street" -> [
        "Holmes would find that most interesting...",
        "That sounds like the beginning of a case!",
        "The game is afoot, as they say!"
      ]
      "chemist" -> [
        "That sounds like it might require a special remedy.",
        "I may have something in my collection for that...",
        "Chemistry can solve many mysteries, you know."
      ]
      "scotland-yard" -> [
        "We'll need to make a note of that in our records.",
        "That could be important evidence!",
        "The law takes such matters very seriously."
      ]
      "docks" -> [
        "Sailors bring all sorts of stories from distant lands.",
        "Strange things wash up with the tide sometimes.",
        "The ships carry more than just cargo, if you know what I mean."
      ]
      "theater" -> [
        "All the world's a stage, as Shakespeare said!",
        "That would make for quite a dramatic scene!",
        "Reality and fiction often blur in these halls."
      ]
      _ -> []
    end

    all_responses = base_responses ++ location_specific_responses
    Enum.random(all_responses)
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
