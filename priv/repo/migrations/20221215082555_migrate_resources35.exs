defmodule AshHq.Repo.Migrations.MigrateResources35 do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    alter table(:guides) do
      modify :sanitized_route, :text, null: false
    end
  end

  def down do
    alter table(:guides) do
      modify :sanitized_route, :text, null: true
    end
  end
end