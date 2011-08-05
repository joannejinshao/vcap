class CreateCustomServiceBindings < ActiveRecord::Migration
  def self.up
    create_table :custom_service_bindings do |t|
      t.references :app
      t.references :custom_service
      t.references :user

      t.timestamps
    end
  end

  def self.down
    drop_table :custom_service_bindings
  end
end
