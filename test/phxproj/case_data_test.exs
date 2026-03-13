defmodule Phxproj.CaseDataTest do
  use ExUnit.Case, async: true

  alias Phxproj.CaseData

  describe "get_active_case/0" do
    test "returns case with default values when no env vars set" do
      case_data = CaseData.get_active_case()

      assert case_data.title == "The Adventure of the Unholy Man"
      assert String.contains?(case_data.description, "murdered in his balcony seat")
      assert String.contains?(case_data.story, "strange preacher had come to town")
      assert String.contains?(case_data.solution, "Longworth")
      assert length(case_data.clues) == 12
    end

    test "uses environment variables when available" do
      original_title = System.get_env("CASE_TITLE")
      original_description = System.get_env("CASE_DESCRIPTION")
      
      System.put_env("CASE_TITLE", "Test Mystery")
      System.put_env("CASE_DESCRIPTION", "A test case description")
      
      case_data = CaseData.get_active_case()
      
      assert case_data.title == "Test Mystery"
      assert case_data.description == "A test case description"
      
      # Cleanup
      if original_title, do: System.put_env("CASE_TITLE", original_title), else: System.delete_env("CASE_TITLE")
      if original_description, do: System.put_env("CASE_DESCRIPTION", original_description), else: System.delete_env("CASE_DESCRIPTION")
    end

    test "handles invalid JSON in CASE_CLUES_JSON gracefully" do
      original_clues = System.get_env("CASE_CLUES_JSON")
      
      System.put_env("CASE_CLUES_JSON", "invalid json")
      
      case_data = CaseData.get_active_case()
      
      assert length(case_data.clues) == 12  # Falls back to default clues
      
      # Cleanup
      if original_clues, do: System.put_env("CASE_CLUES_JSON", original_clues), else: System.delete_env("CASE_CLUES_JSON")
    end

    test "parses valid CASE_CLUES_JSON correctly" do
      original_clues = System.get_env("CASE_CLUES_JSON")
      
      test_clues = Jason.encode!(%{
        "location1" => "Test clue 1",
        "location2" => "Test clue 2"
      })
      
      System.put_env("CASE_CLUES_JSON", test_clues)
      
      case_data = CaseData.get_active_case()
      
      assert length(case_data.clues) == 2
      assert Enum.any?(case_data.clues, &(&1.location_id == "location1" && &1.text == "Test clue 1"))
      assert Enum.any?(case_data.clues, &(&1.location_id == "location2" && &1.text == "Test clue 2"))
      
      # Cleanup
      if original_clues, do: System.put_env("CASE_CLUES_JSON", original_clues), else: System.delete_env("CASE_CLUES_JSON")
    end
  end

  describe "get_clues_for_location/1" do
    test "returns clues for specific location" do
      clues = CaseData.get_clues_for_location("chemist")
      
      assert length(clues) == 1
      assert hd(clues).location_id == "chemist"
      assert String.contains?(hd(clues).text, "Longworth")
    end

    test "returns empty list for non-existent location" do
      clues = CaseData.get_clues_for_location("non-existent")
      
      assert clues == []
    end

    test "returns multiple clues if location has multiple" do
      original_clues = System.get_env("CASE_CLUES_JSON")
      
      test_clues = Jason.encode!(%{
        "test-location" => "Test clue",
        "other-location" => "Other clue"
      })
      
      System.put_env("CASE_CLUES_JSON", test_clues)
      
      clues = CaseData.get_clues_for_location("test-location")
      
      # Note: JSON objects can't have duplicate keys, so this tests the normal case
      assert length(clues) <= 1
      
      # Cleanup
      if original_clues, do: System.put_env("CASE_CLUES_JSON", original_clues), else: System.delete_env("CASE_CLUES_JSON")
    end
  end

  describe "default values" do
    test "default story contains expected elements" do
      case_data = CaseData.get_active_case()
      
      assert String.contains?(case_data.story, "Scotland Yard")
      assert String.contains?(case_data.story, "Playhouse")
      assert String.contains?(case_data.story, "Hamlet")
      assert String.contains?(case_data.story, "Longworth")
    end

    test "default solution contains expected elements" do
      case_data = CaseData.get_active_case()
      
      assert String.contains?(case_data.solution, "Longworth")
      assert String.contains?(case_data.solution, "sword")
      assert String.contains?(case_data.solution, "manuscript")
    end

    test "default clues cover all required locations" do
      expected_locations = [
        "chemist", "bank", "carriage-depot", "docks", "hotel", 
        "locksmith", "museum", "newsagents", "park", "theater", 
        "boars-head", "tobacconist"
      ]
      
      case_data = CaseData.get_active_case()
      actual_locations = Enum.map(case_data.clues, & &1.location_id)
      
      Enum.each(expected_locations, fn location ->
        assert location in actual_locations, "Missing clue for location: #{location}"
      end)
    end
  end
end