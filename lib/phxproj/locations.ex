defmodule Phxproj.Locations do
  @moduledoc """
  Module for managing game locations and their properties.
  """

  defstruct [:id, :name, :description, :can_be_sealed, :special_rules]

  @type t :: %__MODULE__{
    id: String.t(),
    name: String.t(),
    description: String.t(),
    can_be_sealed: boolean(),
    special_rules: String.t() | nil
  }

  @doc """
  Returns all locations.
  """
  def list_all do
    [
      %__MODULE__{
        id: "baker-street",
        name: "221B Baker Street",
        description: "Start/End Location, never any clues associated.",
        can_be_sealed: false,
        special_rules: "Starting location yo"
      },
      %__MODULE__{
        id: "chemist",
        name: "Chemist",
        description: "The local chemist shop.",
        can_be_sealed: true,
        special_rules: nil
      },
      %__MODULE__{
        id: "bank",
        name: "Bank",
        description: "The city bank.",
        can_be_sealed: true,
        special_rules: nil
      },
      %__MODULE__{
        id: "carriage-depot",
        name: "Carriage Depot",
        description: "Where carriages are stored and maintained.",
        can_be_sealed: true,
        special_rules: nil
      },
      %__MODULE__{
        id: "docks",
        name: "Docks",
        description: "The busy harbor docks.",
        can_be_sealed: true,
        special_rules: "Can be accessed from two points of which one must remain unsealed."
      },
      %__MODULE__{
        id: "hotel",
        name: "Hotel",
        description: "A grand hotel.",
        can_be_sealed: true,
        special_rules: nil
      },
      %__MODULE__{
        id: "locksmith",
        name: "Locksmith",
        description: "Provides new keys.",
        can_be_sealed: false,
        special_rules: "Provides new keys, cannot be sealed"
      },
      %__MODULE__{
        id: "museum",
        name: "Museum",
        description: "The city museum.",
        can_be_sealed: true,
        special_rules: nil
      },
      %__MODULE__{
        id: "newsagents",
        name: "Newsagent's",
        description: "The local newspaper shop.",
        can_be_sealed: true,
        special_rules: nil
      },
      %__MODULE__{
        id: "park",
        name: "Park",
        description: "A peaceful park in the city.",
        can_be_sealed: true,
        special_rules: "3 Entrance paths, one must remain unsealed."
      },
      %__MODULE__{
        id: "pawnbroker",
        name: "Pawnbroker",
        description: "A pawnbroker's shop.",
        can_be_sealed: true,
        special_rules: nil
      },
      %__MODULE__{
        id: "theater",
        name: "Theater",
        description: "The local theater.",
        can_be_sealed: true,
        special_rules: nil
      },
      %__MODULE__{
        id: "boars-head",
        name: "Boar's Head",
        description: "A popular tavern.",
        can_be_sealed: true,
        special_rules: nil
      },
      %__MODULE__{
        id: "tobacconist",
        name: "Tobacconist",
        description: "A tobacco shop.",
        can_be_sealed: true,
        special_rules: nil
      },
      %__MODULE__{
        id: "scotland-yard",
        name: "Scotland Yard",
        description: "The police headquarters.",
        can_be_sealed: false,
        special_rules: "Replaces used warrants, cannot be blocked by one."
      }
    ]
  end

  @doc """
  Gets a location by its ID.
  """
  def get_by_id(id) do
    Enum.find(list_all(), &(&1.id == id))
  end

  @doc """
  Gets a location by its name.
  """
  def get_by_name(name) do
    Enum.find(list_all(), &(&1.name == name))
  end
end