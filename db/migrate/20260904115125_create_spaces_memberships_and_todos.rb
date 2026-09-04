class CreateSpacesMembershipsAndTodos < ActiveRecord::Migration[8.1]
  def change
    create_table :spaces do |t|
      t.string :name
      t.text :description
      t.string :slug
      t.references :owner, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
    add_index :spaces, :slug, unique: true

    create_table :space_memberships do |t|
      t.references :user, null: false, foreign_key: true
      t.references :space, null: false, foreign_key: true
      t.string :role

      t.timestamps
    end
    add_index :space_memberships, %i[user_id space_id], unique: true
    add_index :space_memberships, :role

    create_table :todos do |t|
      t.string :name
      t.boolean :completed, default: false, null: false
      t.references :space, null: false, foreign_key: true

      t.timestamps
    end
  end
end
