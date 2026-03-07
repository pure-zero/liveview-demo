defmodule Phxproj.Cases.Clue do
  use Ecto.Schema
  import Ecto.Changeset

  alias Phxproj.Cases.Case

  schema "clues" do
    field :location_id, :string
    field :clue_text, :string
    field :priority, :integer, default: 1

    belongs_to :case, Case

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(clue, attrs) do
    clue
    |> cast(attrs, [:case_id, :location_id, :clue_text, :priority])
    |> validate_required([:case_id, :location_id, :clue_text])
    |> foreign_key_constraint(:case_id)
    |> unique_constraint([:case_id, :location_id])
  end
end