defmodule Pinchflat.Repo.Migrations.CleanupOrphanedTasks do
  use Ecto.Migration

  def up do
    # Delete orphaned tasks where the referenced job no longer exists.
    # This can happen when Oban prunes jobs and SQLite foreign keys are disabled.
    execute("""
    DELETE FROM tasks
    WHERE job_id NOT IN (SELECT id FROM oban_jobs)
    """)
  end

  def down do
    # Cannot restore deleted tasks
    :ok
  end
end
