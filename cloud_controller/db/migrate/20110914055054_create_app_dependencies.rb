class CreateAppDependencies < ActiveRecord::Migration
  def self.up
    create_table :app_dependencies do |t|
      t.column :consumer_id, :app
      t.column :provider_id, :app     

      t.timestamps
    end
  end

  def self.down
    drop_table :app_dependencies
  end
end
