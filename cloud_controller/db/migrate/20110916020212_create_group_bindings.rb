class CreateGroupBindings < ActiveRecord::Migration
  def self.up
    create_table :group_bindings do |t|
      t.references :app
      t.references :group

      t.timestamps
    end
  end

  def self.down
    drop_table :group_bindings
  end
end
