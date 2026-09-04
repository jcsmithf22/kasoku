class UpdateSessionsForRailsAuthentication < ActiveRecord::Migration[7.1]
  def change
    remove_column :sessions, :token_digest, :string
    add_column :sessions, :ip_address, :string
    add_column :sessions, :user_agent, :string
  end
end
