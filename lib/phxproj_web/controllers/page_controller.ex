defmodule PhxprojWeb.PageController do
  use PhxprojWeb, :controller
  
  alias Phxproj.Cases

  def home(conn, _params) do
    active_case = Cases.get_active_case()
    render(conn, :home, case: active_case)
  end
end
