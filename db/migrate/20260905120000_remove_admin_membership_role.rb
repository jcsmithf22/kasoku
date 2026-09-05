class RemoveAdminMembershipRole < ActiveRecord::Migration[8.1]
  def up
    remove_check_constraint :space_memberships, name: "space_memberships_valid_role"
    execute "UPDATE space_memberships SET role = 'member' WHERE role = 'admin'"
    add_check_constraint :space_memberships,
      "role IN ('member', 'viewer')",
      name: "space_memberships_valid_role"
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
