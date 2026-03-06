defmodule PhxprojWeb.SolutionLive do
  use PhxprojWeb, :live_view

  alias Phxproj.OpenAIClient

  @correct_solution """
  The preacher was in fact a thief who had stolen the original manuscript of Hamlet from an exhibit on the Riviera, where he also acquired his tan.

  The preacher disguised the manuscript as a Bible and had Longworth authenticate it for the Duke, whom the preacher hoped would buy it. Longworth, however, in desperate need of money, killed the preacher with Hamlet's sword and stole the manuscript. Longworth, who does not smoke, planted the German made cigarette near the victim's body to throw suspicion from himself, but in the process, he accidentally dropped his packet of aspirin.

  Killer: Longworth; Weapon: Sword; Motive: Manuscript.
  """

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page_title, "Submit Solution")
      |> assign(:solution_form, to_form(%{"explanation" => ""}, as: :solution))
      |> assign(:judgment_result, nil)
      |> assign(:loading, false)

    {:ok, socket}
  end

  @impl true
  def handle_event("submit_solution", %{"solution" => solution_params}, socket) do
    socket = assign(socket, :loading, true)

    # Get the user's solution explanation
    user_solution = solution_params["explanation"]
    
    # Send for AI judgment asynchronously
    send(self(), {:judge_solution, user_solution})

    {:noreply, socket}
  end

  @impl true
  def handle_info({:judge_solution, user_solution}, socket) do
    case judge_solution_with_ai(user_solution) do
      {:ok, judgment} ->
        socket =
          socket
          |> assign(:judgment_result, judgment)
          |> assign(:loading, false)
        
        {:noreply, socket}

      {:error, reason} ->
        socket =
          socket
          |> assign(:judgment_result, %{score: 0, feedback: "Error judging solution: #{reason}"})
          |> assign(:loading, false)
        
        {:noreply, socket}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="min-h-screen bg-gray-900 text-white">
        <div class="mx-auto max-w-4xl p-4 sm:p-6">
          <div class="mb-8 text-center">
            <h1 class="text-3xl sm:text-4xl font-bold mb-4">
              <span class="text-amber-400">Submit Your</span> <span class="text-white">Solution</span>
            </h1>
            <p class="text-gray-300 text-lg">Present your deductions for "The Adventure of the Unholy Man"</p>
          </div>

          <div class="bg-gray-800 rounded-lg border border-gray-700 p-6 shadow-xl">
            <.form 
              for={@solution_form} 
              id="solution-form" 
              phx-submit="submit_solution"
              class="space-y-6"
            >
              <div>
                <label class="block text-sm font-medium text-amber-400 mb-2">
                  Present your complete solution
                </label>
                <p class="text-gray-400 text-sm mb-3">
                  Provide your detailed analysis including who you believe committed the crime, what weapon was used, the motive, and your complete reasoning based on the evidence.
                </p>
                <textarea
                  name="solution[explanation]"
                  rows="12"
                  placeholder="Who killed the preacher and why? What weapon was used? Provide your complete deduction including evidence, reasoning, and how the crime was committed..."
                  class="w-full bg-gray-700 border-gray-600 text-white placeholder-gray-400 focus:border-amber-500 focus:ring-amber-500 rounded-md"
                  required
                ><%= Phoenix.HTML.Form.normalize_value("textarea", @solution_form[:explanation].value) %></textarea>
              </div>

              <div class="flex justify-center">
                <button
                  type="submit"
                  disabled={@loading}
                  class="inline-flex items-center px-8 py-3 text-lg font-semibold rounded-lg bg-gradient-to-r from-amber-600 to-yellow-600 text-black hover:from-amber-500 hover:to-yellow-500 disabled:opacity-50 disabled:cursor-not-allowed transition-all duration-200 shadow-lg"
                >
                  <%= if @loading do %>
                    <svg class="animate-spin -ml-1 mr-3 h-5 w-5 text-black" fill="none" viewBox="0 0 24 24">
                      <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                      <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                    </svg>
                    Judging Solution...
                  <% else %>
                    <.icon name="hero-scale" class="w-5 h-5 mr-2" />
                    Submit for Judgment
                  <% end %>
                </button>
              </div>
            </.form>
          </div>

          <%= if @judgment_result do %>
            <div class="mt-8 bg-gray-800 rounded-lg border border-gray-700 p-6 shadow-xl">
              <div class="text-center mb-6">
                <h2 class="text-2xl font-bold text-amber-400 mb-4">Judgment Results</h2>
                
                <div class="inline-flex items-center justify-center w-24 h-24 rounded-full mb-4" style={"background: conic-gradient(#f59e0b 0% #{@judgment_result.score}%, #374151 #{@judgment_result.score}% 100%)"}>
                  <div class="flex items-center justify-center w-20 h-20 bg-gray-800 rounded-full">
                    <span class="text-2xl font-bold text-white"><%= @judgment_result.score %>%</span>
                  </div>
                </div>

                <div class="mb-4">
                  <%= cond do %>
                    <% @judgment_result.score >= 90 -> %>
                      <p class="text-green-400 text-lg font-semibold">Excellent Detective Work!</p>
                    <% @judgment_result.score >= 75 -> %>
                      <p class="text-blue-400 text-lg font-semibold">Good Deduction!</p>
                    <% @judgment_result.score >= 50 -> %>
                      <p class="text-yellow-400 text-lg font-semibold">On the Right Track</p>
                    <% true -> %>
                      <p class="text-red-400 text-lg font-semibold">Keep Investigating</p>
                  <% end %>
                </div>
              </div>

              <div class="bg-gray-700 rounded-lg p-4">
                <h3 class="text-lg font-semibold text-amber-400 mb-2">Feedback:</h3>
                <p class="text-gray-300 leading-relaxed"><%= @judgment_result.feedback %></p>
              </div>
            </div>
          <% end %>
        </div>
      </div>
    </Layouts.app>
    """
  end


  defp judge_solution_with_ai(user_solution) do
    system_prompt = """
    You are an expert detective judging a solution to "The Adventure of the Unholy Man" mystery. 

    Here is the CORRECT SOLUTION:
    #{@correct_solution}

    Your task:
    1. Carefully analyze the user's complete solution text
    2. Extract who they believe the killer is, what weapon was used, and the motive
    3. Compare their analysis against the correct solution
    4. Award a percentage score from 0-100 based on accuracy
    5. Provide constructive feedback

    Scoring guidelines:
    - Correctly identifying the killer (Longworth): 40 points
    - Correctly identifying the weapon (Sword/Hamlet's sword): 30 points  
    - Correctly identifying the motive (Manuscript theft/money from manuscript): 20 points
    - Quality of explanation, reasoning, and evidence analysis: 10 points

    Look for these key elements in their solution:
    - The preacher was a thief who stole the Hamlet manuscript
    - Longworth killed him to steal the manuscript for money
    - The weapon was Hamlet's sword from the theater
    - The German cigarette was planted by Longworth (who doesn't smoke)
    - The aspirin packet was accidentally dropped by Longworth

    Respond ONLY with valid JSON in this format:
    {
      "score": 85,
      "feedback": "You correctly identified Longworth as the killer and understood that he used a sword from the theater. Your deduction about the manuscript motive shows good detective work. However, you missed the detail that the preacher was originally a thief who had stolen the manuscript from the Riviera. Your reasoning about the planted cigarette evidence was excellent."
    }
    """

    user_prompt = """
    USER'S SOLUTION:
    #{user_solution}
    """

    case OpenAIClient.generate_custom_response(user_prompt, [], system_prompt) do
      {:ok, response} ->
        case Jason.decode(response) do
          {:ok, %{"score" => score, "feedback" => feedback}} when is_integer(score) ->
            {:ok, %{score: min(100, max(0, score)), feedback: feedback}}
          
          {:ok, data} ->
            # Try to extract score if it's a string
            score = case data["score"] do
              s when is_binary(s) ->
                case Integer.parse(s) do
                  {num, _} -> min(100, max(0, num))
                  _ -> 0
                end
              s when is_integer(s) -> min(100, max(0, s))
              _ -> 0
            end
            {:ok, %{score: score, feedback: data["feedback"] || "Unable to provide detailed feedback."}}
          
          _ ->
            {:error, "Invalid response format from AI judge"}
        end

      {:error, reason} ->
        {:error, reason}
    end
  end
end