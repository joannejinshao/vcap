class CreateCustomServices < ActiveRecord::Migration
  def self.up
    create_table :custom_services do |t|
      t.references :app
      t.references :user

      t.timestamps
    end
  end

  def self.down
    drop_table :custom_services
  end
end
