defmodule Phxproj.CaseData do
  @moduledoc """
  Case data management using environment variables.
  """

  defstruct [:title, :description, :story, :solution, :clues]

  @type clue :: %{location_id: String.t(), text: String.t()}
  
  @type t :: %__MODULE__{
    title: String.t(),
    description: String.t(),
    story: String.t(),
    solution: String.t(),
    clues: [clue()]
  }

  @doc """
  Gets the active case from environment variables.
  """
  def get_active_case do
    case_title = get_env_var("CASE_TITLE", "The Adventure of the Unholy Man")
    case_description = get_env_var("CASE_DESCRIPTION", "A strange preacher is found murdered in his balcony seat during a performance of Hamlet.")
    case_story = get_env_var("CASE_STORY", default_story())
    case_solution = get_env_var("CASE_SOLUTION", default_solution())
    case_clues_json = get_env_var("CASE_CLUES_JSON", default_clues_json())

    clues = case Jason.decode(case_clues_json) do
      {:ok, clues_map} ->
        Enum.map(clues_map, fn {location_id, text} ->
          %{location_id: location_id, text: text}
        end)
      {:error, _} ->
        # Fall back to default clues if JSON parsing fails
        default_clues()
    end

    %__MODULE__{
      title: case_title,
      description: case_description,
      story: case_story,
      solution: case_solution,
      clues: clues
    }
  end

  @doc """
  Gets clues for a specific location.
  """
  def get_clues_for_location(location_id) do
    active_case = get_active_case()
    Enum.filter(active_case.clues, &(&1.location_id == location_id))
  end

  defp get_env_var(name, default) do
    System.get_env(name) || default
  end

  defp default_story do
    """
    A strange preacher had come to town, a large morocco-bound Bible under
    his arm. Scotland Yard is puzzled when the preacher is found stabbed to death
    in his balcony seat at the Playhouse during a performance of Hamlet.
         Duchess Tallcourt, who accompanied the victim to the Playhouse,dis-
    covered the body upon returning from the powder room after intermission. The
    preacher's Bible was gone; and on the floor neait)y were a German-made cigar-
    ette and a packet of aspirin.
         It was common knowledge that the Duchess, previously a benefactor of the
    Bishop of Whittenfroth, had come to support the new preacher's views. This
    greatly angered the Bishop and Duke Tallcourt.
         The Longworth Acting Troupe was performing the play, Earl Longworth in
    the lead. Longworth, a rascally cad, had been wooing the Duchess's daughter,
    Anastasia, in hopes of gaining support for his poverty-stricken troupe.
         Scotland Yard wants to know a) who killed the preacher, b) the weapon, and
    c) the motive.
         The game is afoot!
    """
  end

  defp default_solution do
    """
    The preacher was in fact a thief who had stolen the original manuscript of Hamlet from an exhibit on the Riviera, where he also acquired his tan.

    The preacher disguised the manuscript as a Bible and had Longworth authenticate it for the Duke, whom the preacher hoped would buy it. Longworth, however, in desperate need of money, killed the preacher with Hamlet's sword and stole the manuscript. Longworth, who does not smoke, planted the German made cigarette near the victim's body to throw suspicion from himself, but in the process, he accidentally dropped his packet of aspirin.

    Killer: Longworth; Weapon: Sword; Motive: Manuscript.
    """
  end

  defp default_clues_json do
    Jason.encode!(%{
      "chemist" => "You've noticed that Earl Longworth has been coming in frequently for headache remedies - he seems to suffer from constant headaches.",
      "bank" => "Duke Tallcourt is one of our most valued clients. He's a well-known collector of original manuscripts and is said to pay very well for authentic pieces.",
      "carriage-depot" => "Just yesterday, I saw Longworth reading from a Bible to both that victim preacher and Duke Tallcourt. Seemed like he was showing them something important in it.",
      "docks" => "You overheard that strange preacher saying something peculiar: 'You can't judge a book by its cover.' Seemed like an odd thing for a holy man to say.",
      "hotel" => "You've heard from Anastasia, the Duchess's daughter - she mentioned that she did not like that strange preacher at all. Found him quite unsettling.",
      "locksmith" => "You've been asked about this before - one of the stage swords from the theater is missing. Someone must have taken it without permission.",
      "museum" => "Earl Longworth is well-known here - he's considered the foremost authority on the authenticity of original manuscripts. People often bring items to him for verification.",
      "newsagents" => "Big news recently - the original manuscript of Hamlet was stolen from an exhibit on the Riviera! It's been in all the papers. Quite valuable, that would be.",
      "park" => "You often see Earl Longworth here practicing his swordsmanship. He's quite skilled with a blade and comes regularly to practice.",
      "theater" => "You've noticed that the Bishop of Whittenfroth was in attendance at the Playhouse on the night of the murder. That's unusual for him.",
      "boars-head" => "Earl Longworth has been frequenting this place several times in the last month, and from what I can tell, he appears to be having serious money troubles. Been quite worried-looking.",
      "tobacconist" => "The Bishop of Whittenfroth is one of my regular customers - he smokes those German-made cigarettes, quite particular about them. Also, that preacher had quite a handsome tan, which was peculiar for someone in London this time of year."
    })
  end

  defp default_clues do
    [
      %{location_id: "chemist", text: "You've noticed that Earl Longworth has been coming in frequently for headache remedies - he seems to suffer from constant headaches."},
      %{location_id: "bank", text: "Duke Tallcourt is one of our most valued clients. He's a well-known collector of original manuscripts and is said to pay very well for authentic pieces."},
      %{location_id: "carriage-depot", text: "Just yesterday, I saw Longworth reading from a Bible to both that victim preacher and Duke Tallcourt. Seemed like he was showing them something important in it."},
      %{location_id: "docks", text: "You overheard that strange preacher saying something peculiar: 'You can't judge a book by its cover.' Seemed like an odd thing for a holy man to say."},
      %{location_id: "hotel", text: "You've heard from Anastasia, the Duchess's daughter - she mentioned that she did not like that strange preacher at all. Found him quite unsettling."},
      %{location_id: "locksmith", text: "You've been asked about this before - one of the stage swords from the theater is missing. Someone must have taken it without permission."},
      %{location_id: "museum", text: "Earl Longworth is well-known here - he's considered the foremost authority on the authenticity of original manuscripts. People often bring items to him for verification."},
      %{location_id: "newsagents", text: "Big news recently - the original manuscript of Hamlet was stolen from an exhibit on the Riviera! It's been in all the papers. Quite valuable, that would be."},
      %{location_id: "park", text: "You often see Earl Longworth here practicing his swordsmanship. He's quite skilled with a blade and comes regularly to practice."},
      %{location_id: "theater", text: "You've noticed that the Bishop of Whittenfroth was in attendance at the Playhouse on the night of the murder. That's unusual for him."},
      %{location_id: "boars-head", text: "Earl Longworth has been frequenting this place several times in the last month, and from what I can tell, he appears to be having serious money troubles. Been quite worried-looking."},
      %{location_id: "tobacconist", text: "The Bishop of Whittenfroth is one of my regular customers - he smokes those German-made cigarettes, quite particular about them. Also, that preacher had quite a handsome tan, which was peculiar for someone in London this time of year."}
    ]
  end
end