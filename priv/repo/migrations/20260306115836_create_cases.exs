defmodule Phxproj.Repo.Migrations.CreateCases do
  use Ecto.Migration

  def change do
    create table(:cases) do
      add :title, :string, null: false
      add :description, :text
      add :story, :text
      add :solution, :text
      add :active, :boolean, default: false
      add :slug, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:cases, [:slug])
    create index(:cases, [:active])
  end
end
