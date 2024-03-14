class CreateSpaceMemberships < ActiveRecord::Migration[7.1]
  def change
    create_table :space_memberships do |t|
      t.references :user, null: false, foreign_key: true
      t.references :space, null: false, foreign_key: true
      t.string :role

      t.timestamps
    end
    add_index :space_memberships, %i[user_id space_id], unique: true
    add_index :space_memberships, :role
  end
end
