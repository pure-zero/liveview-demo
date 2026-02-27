defmodule PhxprojWeb.PageController do
  use PhxprojWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
