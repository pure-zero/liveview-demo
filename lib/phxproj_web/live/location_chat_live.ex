defmodule PhxprojWeb.LocationChatLive do
  use PhxprojWeb, :live_view

  alias Phxproj.Locations

  @impl true
  def mount(%{"location_id" => location_id}, _session, socket) do
    location = Locations.get_by_id(location_id)

    if location do
      socket =
        socket
        |> assign(:page_title, location.name)
        |> assign(:location, location)
        |> assign(:messages, initial_messages(location))
        |> assign(:message_form, to_form(%{"content" => ""}, as: :message))

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

        response = generate_location_response(socket.assigns.location, content)
        
        location_message = %{
          id: System.unique_integer([:positive]),
          content: response,
          sender: :location,
          timestamp: DateTime.utc_now()
        }

        messages = socket.assigns.messages ++ [user_message, location_message]

        socket
        |> assign(:messages, messages)
        |> assign(:message_form, to_form(%{"content" => ""}, as: :message))
      else
        socket
      end

    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="mx-auto max-w-4xl p-6">
        <div class="mb-6">
          <div class="flex items-center justify-between mb-4">
            <div class="flex items-center space-x-4">
              <.link 
                navigate={~p"/locations"} 
                class="text-indigo-600 hover:text-indigo-700 flex items-center text-sm font-medium"
              >
                <.icon name="hero-arrow-left" class="w-4 h-4 mr-1" />
                Back to Locations
              </.link>
            </div>
          </div>

          <div class="bg-white rounded-lg border border-gray-200 p-6 mb-6">
            <div class="flex items-start justify-between">
              <div>
                <h1 class="text-3xl font-bold text-gray-900 mb-2">{@location.name}</h1>
                <p class="text-gray-600 mb-3">{@location.description}</p>
                <%= if @location.special_rules do %>
                  <div class="inline-flex items-center px-3 py-1 rounded-full text-sm bg-amber-100 text-amber-800">
                    <.icon name="hero-exclamation-triangle" class="w-4 h-4 mr-1" />
                    {@location.special_rules}
                  </div>
                <% end %>
              </div>
              <%= if not @location.can_be_sealed do %>
                <span class="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-blue-100 text-blue-800">
                  <.icon name="hero-shield-check" class="w-4 h-4 mr-1" />
                  Protected Location
                </span>
              <% end %>
            </div>
          </div>
        </div>

        <div class="bg-white rounded-lg border border-gray-200 flex flex-col h-96">
          <div class="flex-1 overflow-y-auto p-4 space-y-4" id="chat-messages" phx-update="ignore">
            <div :for={message <- @messages} class={[
              "flex",
              if(message.sender == :user, do: "justify-end", else: "justify-start")
            ]}>
              <div class={[
                "max-w-xs lg:max-w-md px-4 py-2 rounded-lg text-sm",
                if(message.sender == :user, 
                  do: "bg-indigo-600 text-white", 
                  else: "bg-gray-100 text-gray-900")
              ]}>
                <p class="break-words">{message.content}</p>
                <p class={[
                  "text-xs mt-1",
                  if(message.sender == :user, do: "text-indigo-200", else: "text-gray-500")
                ]}>
                  {format_time(message.timestamp)}
                </p>
              </div>
            </div>
          </div>

          <div class="border-t border-gray-200 p-4">
            <.form 
              for={@message_form} 
              id="message-form" 
              phx-submit="send_message"
              class="flex space-x-2"
            >
              <.input
                field={@message_form[:content]}
                type="text"
                placeholder="Type your message..."
                class="flex-1"
                autocomplete="off"
              />
              <button
                type="submit"
                class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
              >
                <.icon name="hero-paper-airplane" class="w-4 h-4" />
              </button>
            </.form>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  defp initial_messages(location) do
    welcome_message = case location.id do
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

    [
      %{
        id: 1,
        content: welcome_message,
        sender: :location,
        timestamp: DateTime.utc_now()
      }
    ]
  end

  defp generate_location_response(location, user_message) do
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
end