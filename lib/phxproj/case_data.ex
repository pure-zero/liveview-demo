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
    case_title = System.get_env("CASE_TITLE")
    case_description = System.get_env("CASE_DESCRIPTION") || ""
    case_story = System.get_env("CASE_STORY") || ""
    case_solution = System.get_env("CASE_SOLUTION") || ""
    case_clues_json = System.get_env("CASE_CLUES_JSON") || "{}"

    if is_nil(case_title) do
      nil
    else
      clues = case Jason.decode(case_clues_json) do
        {:ok, clues_map} ->
          Enum.map(clues_map, fn {location_id, text} ->
            %{location_id: location_id, text: text}
          end)
        {:error, _} ->
          []
      end

      %__MODULE__{
        title: case_title,
        description: case_description,
        story: String.replace(case_story, "\\n", "\n"),
        solution: case_solution,
        clues: clues
      }
    end
  end

  @doc """
  Gets clues for a specific location.
  """
  def get_clues_for_location(location_id) do
    case get_active_case() do
      nil -> []
      active_case -> Enum.filter(active_case.clues, &(&1.location_id == location_id))
    end
  end

end
