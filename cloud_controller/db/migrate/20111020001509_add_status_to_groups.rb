class AddStatusToGroups < ActiveRecord::Migration
  def self.up
    add_column :groups, :status, :string
  end

  def self.down
  end
end
