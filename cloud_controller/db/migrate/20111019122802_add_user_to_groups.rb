class AddUserToGroups < ActiveRecord::Migration
  def self.up
    add_column :groups, :user_id, :integer
  end

  def self.down
  end
end
