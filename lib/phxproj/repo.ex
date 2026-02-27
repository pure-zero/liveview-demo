defmodule Phxproj.Repo do
  use Ecto.Repo,
    otp_app: :phxproj,
    adapter: Ecto.Adapters.Postgres
end
