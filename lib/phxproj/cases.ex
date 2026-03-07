defmodule Phxproj.Cases do
  @moduledoc """
  The Cases context.
  """

  import Ecto.Query, warn: false
  alias Phxproj.Repo

  alias Phxproj.Cases.Case
  alias Phxproj.Cases.Clue

  @doc """
  Returns the list of cases.

  ## Examples

      iex> list_cases()
      [%Case{}, ...]

  """
  def list_cases do
    Repo.all(Case)
  end

  @doc """
  Gets the active case.

  ## Examples

      iex> get_active_case()
      %Case{}

      iex> get_active_case()
      nil

  """
  def get_active_case do
    Repo.one(from c in Case, where: c.active == true)
  end

  @doc """
  Gets a single case.

  Raises `Ecto.NoResultsError` if the Case does not exist.

  ## Examples

      iex> get_case!(123)
      %Case{}

      iex> get_case!(456)
      ** (Ecto.NoResultsError)

  """
  def get_case!(id), do: Repo.get!(Case, id)

  @doc """
  Gets a case by slug.

  ## Examples

      iex> get_case_by_slug("unholy-man")
      %Case{}

      iex> get_case_by_slug("nonexistent")
      nil

  """
  def get_case_by_slug(slug) do
    Repo.one(from c in Case, where: c.slug == ^slug)
  end

  @doc """
  Creates a case.

  ## Examples

      iex> create_case(%{field: value})
      {:ok, %Case{}}

      iex> create_case(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_case(attrs \\ %{}) do
    %Case{}
    |> Case.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a case.

  ## Examples

      iex> update_case(case, %{field: new_value})
      {:ok, %Case{}}

      iex> update_case(case, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_case(%Case{} = case, attrs) do
    case
    |> Case.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a case.

  ## Examples

      iex> delete_case(case)
      {:ok, %Case{}}

      iex> delete_case(case)
      {:error, %Ecto.Changeset{}}

  """
  def delete_case(%Case{} = case) do
    Repo.delete(case)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking case changes.

  ## Examples

      iex> change_case(case)
      %Ecto.Changeset{data: %Case{}}

  """
  def change_case(%Case{} = case, attrs \\ %{}) do
    Case.changeset(case, attrs)
  end

  @doc """
  Gets clues for a case and location.

  ## Examples

      iex> get_clues_for_location(case_id, "baker-street")
      [%Clue{}]

  """
  def get_clues_for_location(case_id, location_id) do
    Repo.all(from c in Clue, where: c.case_id == ^case_id and c.location_id == ^location_id)
  end

  @doc """
  Gets all clues for a case.

  ## Examples

      iex> get_case_clues(case_id)
      [%Clue{}, ...]

  """
  def get_case_clues(case_id) do
    Repo.all(from c in Clue, where: c.case_id == ^case_id, order_by: [asc: c.priority, asc: c.location_id])
  end

  @doc """
  Creates a clue.

  ## Examples

      iex> create_clue(%{field: value})
      {:ok, %Clue{}}

      iex> create_clue(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_clue(attrs \\ %{}) do
    %Clue{}
    |> Clue.changeset(attrs)
    |> Repo.insert()
  end
end