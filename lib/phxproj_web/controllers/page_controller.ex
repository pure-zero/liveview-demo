defmodule PhxprojWeb.PageController do
  use PhxprojWeb, :controller
  
  alias Phxproj.CaseData

  def home(conn, _params) do
    active_case = CaseData.get_active_case()
    render(conn, :home, case: active_case)
  end
end
