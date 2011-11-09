class AddDestinationsToPorts < ActiveRecord::Migration
  def self.up
    add_column :ports, :port_type, :string
    add_column :ports, :path, :string
    add_column :ports, :placeholder, :string
  end

  def self.down
    remove_column :ports, :placeholder
    remove_column :ports, :path
    remove_column :ports, :port_type
  end
end
