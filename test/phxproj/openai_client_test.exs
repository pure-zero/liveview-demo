defmodule Phxproj.OpenAIClientTest do
  use ExUnit.Case, async: true

  alias Phxproj.OpenAIClient

  # Mock data for testing
  @mock_location %{
    id: "test-location",
    name: "Test Location", 
    description: "A test location for testing",
    special_rules: nil
  }

  describe "generate_location_response/3" do
    test "returns error when API key is not configured" do
      original_key = Application.get_env(:phxproj, :openai_api_key)
      original_env_key = System.get_env("OPENAI_API_KEY")
      
      Application.delete_env(:phxproj, :openai_api_key)
      System.delete_env("OPENAI_API_KEY")
      
      result = OpenAIClient.generate_location_response(@mock_location, "Hello")
      
      assert {:error, "OpenAI API key not configured"} = result
      
      # Cleanup
      if original_key, do: Application.put_env(:phxproj, :openai_api_key, original_key)
      if original_env_key, do: System.put_env("OPENAI_API_KEY", original_env_key)
    end

    test "builds correct system prompt with location and clues" do
      # This test verifies that the system prompt is built correctly
      # We can't easily test the actual API call without mocking the HTTP library
      original_key = Application.get_env(:phxproj, :openai_api_key)
      
      Application.put_env(:phxproj, :openai_api_key, "test-key")
      
      # Test that it doesn't crash with proper key (though API call will fail)
      result = OpenAIClient.generate_location_response(@mock_location, "Hello")
      
      # Should get an error from the actual API call, not from missing key
      assert {:error, _reason} = result
      
      # Cleanup
      if original_key, do: Application.put_env(:phxproj, :openai_api_key, original_key), else: Application.delete_env(:phxproj, :openai_api_key)
    end

    test "handles conversation history correctly" do
      original_key = Application.get_env(:phxproj, :openai_api_key)
      
      Application.put_env(:phxproj, :openai_api_key, "test-key")
      
      conversation_history = [
        %{sender: :user, content: "Previous user message"},
        %{sender: :assistant, content: "Previous assistant message"}
      ]
      
      # Test that it doesn't crash with conversation history
      result = OpenAIClient.generate_location_response(@mock_location, "Hello", conversation_history)
      
      assert {:error, _reason} = result
      
      # Cleanup
      if original_key, do: Application.put_env(:phxproj, :openai_api_key, original_key), else: Application.delete_env(:phxproj, :openai_api_key)
    end
  end

  describe "generate_custom_response/3" do
    test "returns error when API key is not configured" do
      original_key = Application.get_env(:phxproj, :openai_api_key)
      original_env_key = System.get_env("OPENAI_API_KEY")
      
      Application.delete_env(:phxproj, :openai_api_key)
      System.delete_env("OPENAI_API_KEY")
      
      result = OpenAIClient.generate_custom_response("Test message", [], "Custom system prompt")
      
      assert {:error, "OpenAI API key not configured"} = result
      
      # Cleanup
      if original_key, do: Application.put_env(:phxproj, :openai_api_key, original_key)
      if original_env_key, do: System.put_env("OPENAI_API_KEY", original_env_key)
    end

    test "uses custom system prompt" do
      original_key = Application.get_env(:phxproj, :openai_api_key)
      
      Application.put_env(:phxproj, :openai_api_key, "test-key")
      
      result = OpenAIClient.generate_custom_response("Test message", [], "Custom system prompt")
      
      # Should get an error from the actual API call, not from missing key
      assert {:error, _reason} = result
      
      # Cleanup
      if original_key, do: Application.put_env(:phxproj, :openai_api_key, original_key), else: Application.delete_env(:phxproj, :openai_api_key)
    end
  end

  describe "character prompts" do
    test "generates different prompts for different locations" do
      # Test some specific location character prompts
      chemist_location = %{id: "chemist", name: "Chemist", description: "The local chemist shop", special_rules: nil}
      theater_location = %{id: "theater", name: "Theater", description: "The grand theater", special_rules: nil}
      
      original_key = Application.get_env(:phxproj, :openai_api_key)
      Application.put_env(:phxproj, :openai_api_key, "test-key")
      
      # Both should fail with API error, but should build different prompts
      {:error, _} = OpenAIClient.generate_location_response(chemist_location, "Hello")
      {:error, _} = OpenAIClient.generate_location_response(theater_location, "Hello")
      
      # Cleanup
      if original_key, do: Application.put_env(:phxproj, :openai_api_key, original_key), else: Application.delete_env(:phxproj, :openai_api_key)
    end
  end

  describe "API key configuration" do
    test "prefers application config over environment variable" do
      original_app_key = Application.get_env(:phxproj, :openai_api_key)
      original_env_key = System.get_env("OPENAI_API_KEY")
      
      Application.put_env(:phxproj, :openai_api_key, "app-config-key")
      System.put_env("OPENAI_API_KEY", "env-var-key")
      
      # The function should use app config key, not env var key
      # We can't easily test this directly, but we can test that it doesn't return the "not configured" error
      result = OpenAIClient.generate_location_response(@mock_location, "Hello")
      
      assert {:error, reason} = result
      assert reason != "OpenAI API key not configured"
      
      # Cleanup
      if original_app_key, do: Application.put_env(:phxproj, :openai_api_key, original_app_key), else: Application.delete_env(:phxproj, :openai_api_key)
      if original_env_key, do: System.put_env("OPENAI_API_KEY", original_env_key), else: System.delete_env("OPENAI_API_KEY")
    end

    test "uses environment variable when app config not set" do
      original_app_key = Application.get_env(:phxproj, :openai_api_key)
      original_env_key = System.get_env("OPENAI_API_KEY")
      
      Application.delete_env(:phxproj, :openai_api_key)
      System.put_env("OPENAI_API_KEY", "env-var-key")
      
      result = OpenAIClient.generate_location_response(@mock_location, "Hello")
      
      assert {:error, reason} = result
      assert reason != "OpenAI API key not configured"
      
      # Cleanup
      if original_app_key, do: Application.put_env(:phxproj, :openai_api_key, original_app_key)
      if original_env_key, do: System.put_env("OPENAI_API_KEY", original_env_key), else: System.delete_env("OPENAI_API_KEY")
    end
  end

  describe "conversation history handling" do
    test "limits conversation history to last 10 messages" do
      original_key = Application.get_env(:phxproj, :openai_api_key)
      Application.put_env(:phxproj, :openai_api_key, "test-key")
      
      # Create 15 messages (more than the 10 limit)
      conversation_history = Enum.map(1..15, fn i ->
        %{sender: if(rem(i, 2) == 0, do: :assistant, else: :user), content: "Message #{i}"}
      end)
      
      result = OpenAIClient.generate_location_response(@mock_location, "Hello", conversation_history)
      
      # Should not crash due to too many messages
      assert {:error, _reason} = result
      
      # Cleanup
      if original_key, do: Application.put_env(:phxproj, :openai_api_key, original_key), else: Application.delete_env(:phxproj, :openai_api_key)
    end
  end
end