defmodule Phxproj.Cases.Case do
  use Ecto.Schema
  import Ecto.Changeset

  alias Phxproj.Cases.Clue

  schema "cases" do
    field :title, :string
    field :description, :string
    field :story, :string
    field :solution, :string
    field :active, :boolean, default: false
    field :slug, :string

    has_many :clues, Clue

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(case, attrs) do
    case
    |> cast(attrs, [:title, :description, :story, :solution, :active, :slug])
    |> validate_required([:title, :slug])
    |> unique_constraint(:slug)
    |> validate_format(:slug, ~r/^[a-z0-9-]+$/, message: "must contain only lowercase letters, numbers, and dashes")
  end
end