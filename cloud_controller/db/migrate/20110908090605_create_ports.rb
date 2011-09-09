class CreatePorts < ActiveRecord::Migration
  def self.up
    create_table :ports do |t|
      t.string :name
      t.boolean :primary
      t.integer :index
      t.references :app

      t.timestamps
    end
  end

  def self.down
    drop_table :ports
  end
end
