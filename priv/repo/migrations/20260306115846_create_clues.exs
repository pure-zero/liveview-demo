defmodule Phxproj.Repo.Migrations.CreateClues do
  use Ecto.Migration

  def change do
    create table(:clues) do
      add :case_id, references(:cases, on_delete: :delete_all), null: false
      add :location_id, :string, null: false
      add :clue_text, :text, null: false
      add :priority, :integer, default: 1

      timestamps(type: :utc_datetime)
    end

    create index(:clues, [:case_id])
    create index(:clues, [:location_id])
    create unique_index(:clues, [:case_id, :location_id])
  end
end
