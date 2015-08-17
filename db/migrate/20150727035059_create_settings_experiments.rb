class CreateSettingsExperiments < ActiveRecord::Migration
  def change
    create_table :settings_experiments do |t|
      t.string :name
      t.string :fullname
      t.string :description

      t.timestamps null: false
    end
  end
end