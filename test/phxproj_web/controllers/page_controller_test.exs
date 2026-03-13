defmodule PhxprojWeb.PageControllerTest do
  use PhxprojWeb.ConnCase

  describe "GET /" do
    test "renders the home page with case information", %{conn: conn} do
      conn = get(conn, ~p"/")
      response = html_response(conn, 200)
      
      assert response =~ "221B"
      assert response =~ "Baker Street"
      assert response =~ "The Adventure of the Unholy Man"
      assert response =~ "strange preacher"
      assert response =~ "Scotland Yard"
    end

    test "includes dark mode styling", %{conn: conn} do
      conn = get(conn, ~p"/")
      response = html_response(conn, 200)
      
      assert response =~ "bg-gray-900" || response =~ "dark"
      assert response =~ "text-white"
    end

    test "shows navigation to locations", %{conn: conn} do
      conn = get(conn, ~p"/")
      response = html_response(conn, 200)
      
      assert response =~ "/locations"
    end

    test "shows navigation to solution submission", %{conn: conn} do
      conn = get(conn, ~p"/")
      response = html_response(conn, 200)
      
      assert response =~ "/solution"
    end

    test "displays case story from environment variables", %{conn: conn} do
      # Test that the page uses CaseData module
      original_story = System.get_env("CASE_STORY")
      
      test_story = "This is a test mystery story for testing purposes."
      System.put_env("CASE_STORY", test_story)
      
      conn = get(conn, ~p"/")
      response = html_response(conn, 200)
      
      assert response =~ "test mystery story"
      
      # Cleanup
      if original_story, do: System.put_env("CASE_STORY", original_story), else: System.delete_env("CASE_STORY")
    end

    test "displays case title from environment variables", %{conn: conn} do
      original_title = System.get_env("CASE_TITLE")
      
      test_title = "Test Mystery Case"
      System.put_env("CASE_TITLE", test_title)
      
      conn = get(conn, ~p"/")
      response = html_response(conn, 200)
      
      assert response =~ "Test Mystery Case"
      
      # Cleanup
      if original_title, do: System.put_env("CASE_TITLE", original_title), else: System.delete_env("CASE_TITLE")
    end

    test "handles missing environment variables gracefully", %{conn: conn} do
      # Remove all case-related env vars to test defaults
      original_vars = %{
        title: System.get_env("CASE_TITLE"),
        description: System.get_env("CASE_DESCRIPTION"),
        story: System.get_env("CASE_STORY")
      }
      
      System.delete_env("CASE_TITLE")
      System.delete_env("CASE_DESCRIPTION") 
      System.delete_env("CASE_STORY")
      
      conn = get(conn, ~p"/")
      response = html_response(conn, 200)
      
      # Should use default values
      assert response =~ "The Adventure of the Unholy Man"
      assert response =~ "strange preacher"
      
      # Cleanup
      Enum.each(original_vars, fn {key, value} ->
        if value, do: System.put_env(Atom.to_string(key) |> String.upcase() |> String.replace_prefix("", "CASE_"), value)
      end)
    end

    test "page loads successfully without database", %{conn: conn} do
      # This test verifies that the page works without PostgreSQL
      conn = get(conn, ~p"/")
      
      assert response(conn, 200)
      # Should not have any database-related errors
    end

    test "includes Victorian theme styling", %{conn: conn} do
      conn = get(conn, ~p"/")
      response = html_response(conn, 200)
      
      # Check for Victorian/mystery theme elements
      assert response =~ "amber"
    end

    test "mobile responsive design", %{conn: conn} do
      conn = get(conn, ~p"/")
      response = html_response(conn, 200)
      
      # Check for responsive classes
      assert response =~ "sm:" || response =~ "md:" || response =~ "lg:"
      assert response =~ "max-w" || response =~ "mx-auto"
    end

    test "shows case description", %{conn: conn} do
      conn = get(conn, ~p"/")
      response = html_response(conn, 200)
      
      assert response =~ "murdered" || response =~ "balcony seat" || response =~ "Hamlet"
    end
  end

  describe "controller assigns" do
    test "assigns case data to template", %{conn: conn} do
      conn = get(conn, ~p"/")
      
      # The assigns should include the case data
      assert conn.assigns.case
      assert conn.assigns.case.title
      assert conn.assigns.case.story
    end

    test "case data comes from CaseData module", %{conn: conn} do
      # Test that controller uses CaseData.get_active_case()
      case_data = Phxproj.CaseData.get_active_case()
      
      conn = get(conn, ~p"/")
      
      # The assigned case should match what CaseData returns
      assert conn.assigns.case.title == case_data.title
      assert conn.assigns.case.story == case_data.story
    end
  end
end
