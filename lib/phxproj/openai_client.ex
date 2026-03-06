defmodule Phxproj.OpenAIClient do
  @moduledoc """
  Client for interacting with OpenAI's ChatGPT API using Req.
  """

  @api_url "https://api.openai.com/v1/chat/completions"

  @doc """
  Generates a location-specific response using ChatGPT.
  """
  def generate_location_response(location, user_message, conversation_history \\ []) do
    system_prompt = build_system_prompt(location)
    generate_response_with_system_prompt(system_prompt, user_message, conversation_history)
  end

  @doc """
  Generates a response using a custom system prompt.
  """
  def generate_custom_response(user_message, conversation_history \\ [], custom_system_prompt) do
    generate_response_with_system_prompt(custom_system_prompt, user_message, conversation_history)
  end

  defp generate_response_with_system_prompt(system_prompt, user_message, conversation_history) do
    case get_api_key() do
      nil ->
        {:error, "OpenAI API key not configured"}

      api_key ->
        messages = build_messages(system_prompt, conversation_history, user_message)

        case call_openai_api(api_key, messages) do
          {:ok, response} ->
            {:ok, response}

          {:error, reason} ->
            {:error, reason}
        end
    end
  end

  defp get_api_key do
    Application.get_env(:phxproj, :openai_api_key) ||
      System.get_env("OPENAI_API_KEY")
  end

  defp build_system_prompt(location) do
    base_prompt = """
    You are roleplaying as a character at #{location.name} in Victorian London. 
    
    Location Description: #{location.description}
    """

    location_specific_prompt = case location.id do
      "baker-street" ->
        "You are Mrs. Hudson, the landlady of 221B Baker Street. You're familiar with Sherlock Holmes and Dr. Watson's cases. Be helpful but also mention interesting details about the famous detective's habits."

      "chemist" ->
        "You are the local chemist. You know about various medicines, potions, and chemicals. You're knowledgeable about both legitimate remedies and more... questionable substances that might be used in detective work."

      "scotland-yard" ->
        "You are Inspector Lestrade or another police inspector. You're professional but sometimes frustrated with amateur detectives. You deal with warrants, evidence, and official police business."

      "docks" ->
        "You are a dock worker or sailor. You've seen ships come and go, heard rumors from distant lands, and know about the less savory characters who frequent the waterfront."

      "theater" ->
        "You are an actor or theater manager. You know about dramatic performances, costumes, makeup, and the theatrical world. You might have information about people who frequent the arts."

      "locksmith" ->
        "You are the local locksmith. You make and repair keys, understand security, and know about who needs access to various places. You're practical and security-minded."

      "park" ->
        "You are a park attendant or regular visitor. You know about people's habits, who meets whom, and the daily routines of those who frequent this peaceful space."

      "museum" ->
        "You are a museum curator or guard. You're knowledgeable about artifacts, history, and the valuable items in your collection. You notice details and remember visitors."

      "hotel" ->
        "You are the hotel concierge or manager. You're discreet but observant, knowing about guests' comings and goings, and you provide services to travelers."

      "bank" ->
        "You are a bank clerk or manager. You handle financial matters, know about transactions, and understand the monetary affairs of the city's residents."

      "newsagents" ->
        "You are the newsagent. You know all the latest gossip, news, and rumors. People tell you things, and you hear everything that's happening in the neighborhood."

      "pawnbroker" ->
        "You are the pawnbroker. You deal in valuable items, know their worth, and often learn interesting stories about why people need quick money."

      "tobacconist" ->
        "You are the tobacco shop owner. You know your customers' preferences, and people often chat while selecting their tobacco. You're observant and a good listener."

      "boars-head" ->
        "You are the tavern keeper or a regular patron. You serve drinks, hear stories, and know the local gossip. The atmosphere is friendly but you're always listening."

      "carriage-depot" ->
        "You are a carriage driver or depot manager. You know about transportation around the city, where people go, and you overhear many conversations during rides."

      _ ->
        "You are a helpful local person who knows about your area and the people who frequent it."
    end

    special_rules_prompt = if location.special_rules do
      "\n\nImportant: #{location.special_rules}"
    else
      ""
    end

    base_prompt <> "\n\n" <> location_specific_prompt <> special_rules_prompt <> """

    
    Keep your responses:
    - In character for Victorian London (1880s-1890s)
    - Conversational and engaging
    - Helpful but also realistic to your role
    - Around 1-3 sentences unless asked for more detail
    - Include relevant details about your location or expertise when appropriate
    """
  end

  defp build_messages(system_prompt, conversation_history, user_message) do
    system_message = %{"role" => "system", "content" => system_prompt}
    
    history_messages = 
      conversation_history
      |> Enum.take(-10)  # Keep last 10 messages for context
      |> Enum.map(fn message ->
        role = if message.sender == :user, do: "user", else: "assistant"
        %{"role" => role, "content" => message.content}
      end)

    user_message = %{"role" => "user", "content" => user_message}

    [system_message] ++ history_messages ++ [user_message]
  end

  defp call_openai_api(api_key, messages) do
    headers = [
      {"Authorization", "Bearer #{api_key}"},
      {"Content-Type", "application/json"}
    ]

    body = %{
      "model" => "gpt-3.5-turbo",
      "messages" => messages,
      "max_tokens" => 150,
      "temperature" => 0.8
    }

    case Req.post(@api_url, headers: headers, json: body) do
      {:ok, %{status: 200, body: response_body}} ->
        case extract_response_content(response_body) do
          {:ok, content} -> {:ok, content}
          {:error, reason} -> {:error, reason}
        end

      {:ok, %{status: status, body: body}} ->
        {:error, "API request failed with status #{status}: #{inspect(body)}"}

      {:error, reason} ->
        {:error, "Network error: #{inspect(reason)}"}
    end
  end

  defp extract_response_content(%{"choices" => [%{"message" => %{"content" => content}} | _]}) do
    {:ok, String.trim(content)}
  end

  defp extract_response_content(response) do
    {:error, "Unexpected response format: #{inspect(response)}"}
  end
end