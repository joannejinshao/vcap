class CreateAppRuntimes < ActiveRecord::Migration
  def self.up
    create_table :app_runtimes do |t|
      t.string :main
      t.string :lib_path
      t.references :app

      t.timestamps
    end
  end

  def self.down
    drop_table :app_runtimes
  end
end
