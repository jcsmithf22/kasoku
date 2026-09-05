class RemoveOwnerMemberships < ActiveRecord::Migration[8.1]
  def up
    execute <<~SQL
      DELETE FROM space_memberships
      WHERE EXISTS (
        SELECT 1 FROM spaces
        WHERE spaces.id = space_memberships.space_id
          AND spaces.owner_id = space_memberships.user_id
      )
    SQL

    # Preserve access for non-owners previously assigned the owner role.
    execute "UPDATE space_memberships SET role = 'admin' WHERE role = 'owner'"

    change_column_null :space_memberships, :role, false
    add_check_constraint :space_memberships,
      "role IN ('admin', 'member', 'viewer')",
      name: "space_memberships_valid_role"
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
