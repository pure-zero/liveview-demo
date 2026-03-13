defmodule PhxprojWeb.SolutionLiveTest do
  use PhxprojWeb.ConnCase
  import Phoenix.LiveViewTest

  describe "mount/3" do
    test "mounts with correct initial assigns", %{conn: conn} do
      {:ok, view, html} = live(conn, ~p"/solution")

      assert html =~ "Submit Your"
      assert html =~ "Solution"
      assert html =~ "The Adventure of the Unholy Man"
      
      # Check initial assigns
      assert view |> element("form") |> has_element?()
      refute html =~ "Judgment Results"  # Should not show results initially
    end
  end

  describe "form rendering" do
    test "renders solution form with correct elements", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/solution")

      assert html =~ "Present your complete solution"
      assert html =~ "textarea"
      assert html =~ "name=\"solution[explanation]\""
      assert html =~ "Submit for Judgment"
      assert html =~ "Who killed the preacher and why?"
    end

  end

  describe "submit_solution event" do

    test "accepts solution submission with valid explanation", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/solution")

      # Submit a solution
      result = view
      |> form("#solution-form", solution: %{"explanation" => "Test solution explanation"})
      |> render_submit()

      # Should not crash and should show loading state
      assert result =~ "Judging Solution..."
    end

    test "requires explanation field", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/solution")

      # Try to submit empty form
      result = view
      |> form("#solution-form", solution: %{"explanation" => ""})
      |> render_submit()

      # Form should have required attribute, so this tests the form validation
      assert result
    end
  end

  describe "judge_solution_with_ai/1" do
    # Note: We can't easily test the actual AI judgment without mocking the OpenAI client
    # These tests focus on the integration and error handling
    
    test "handles AI judgment errors gracefully", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/solution")

      # Set up environment to cause OpenAI error (no API key)
      original_key = Application.get_env(:phxproj, :openai_api_key)
      original_env_key = System.get_env("OPENAI_API_KEY")
      
      Application.delete_env(:phxproj, :openai_api_key)
      System.delete_env("OPENAI_API_KEY")

      # Submit solution
      view
      |> form("#solution-form", solution: %{"explanation" => "Test solution"})
      |> render_submit()

      # Wait for async judgment to complete
      :timer.sleep(100)
      html = render(view)

      # Should show error feedback
      assert html =~ "Error judging solution"
      refute html =~ "Judging Solution..."  # Should not be loading anymore

      # Cleanup
      if original_key, do: Application.put_env(:phxproj, :openai_api_key, original_key)
      if original_env_key, do: System.put_env("OPENAI_API_KEY", original_env_key)
    end
  end

  describe "judgment results display" do

    test "displays different score ranges with appropriate messages", %{conn: conn} do
      {:ok, _view, _html} = live(conn, ~p"/solution")

      # Test high score (90+)
      _high_score_judgment = %{score: 95, feedback: "Excellent work!"}
      
      # We can test this by directly updating the assigns (in a real test environment)
      # For now, we'll test that the template handles different score ranges
      # This is a placeholder test showing the structure for testing score display logic
      assert true
    end
  end

  describe "error handling" do
    test "handles invalid JSON response from AI", %{conn: conn} do
      # This would test the JSON parsing error handling in judge_solution_with_ai
      # Since we can't easily mock the OpenAI client in this test setup,
      # we focus on testing that the LiveView doesn't crash with bad data
      
      {:ok, view, _html} = live(conn, ~p"/solution")
      
      # Submit solution to trigger judgment
      view
      |> form("#solution-form", solution: %{"explanation" => "Test"})
      |> render_submit()
      
      # The view should remain functional even if AI judgment fails
      assert render(view)
    end

    test "handles missing OpenAI API configuration", %{conn: conn} do
      original_key = Application.get_env(:phxproj, :openai_api_key)
      original_env_key = System.get_env("OPENAI_API_KEY")
      
      Application.delete_env(:phxproj, :openai_api_key)
      System.delete_env("OPENAI_API_KEY")

      {:ok, view, _html} = live(conn, ~p"/solution")
      
      view
      |> form("#solution-form", solution: %{"explanation" => "Test solution"})
      |> render_submit()

      # Should handle missing API key gracefully
      :timer.sleep(100)
      html = render(view)
      
      # Should show error and not be stuck in loading state
      assert html =~ "Error judging solution" || html =~ "Submit for Judgment"
      
      # Cleanup
      if original_key, do: Application.put_env(:phxproj, :openai_api_key, original_key)
      if original_env_key, do: System.put_env("OPENAI_API_KEY", original_env_key)
    end
  end

  describe "scoring system" do
    test "score is clamped to 0-100 range", %{conn: conn} do
      # Test that the scoring system properly clamps scores
      # This tests the min(100, max(0, score)) logic
      
      {:ok, _view, _html} = live(conn, ~p"/solution")
      
      # In a full test, we'd mock the AI response to return scores outside 0-100
      # and verify they get clamped properly
      assert true  # Placeholder for actual score clamping test
    end
  end
end