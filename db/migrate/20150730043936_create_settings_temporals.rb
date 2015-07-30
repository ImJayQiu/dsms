class CreateSettingsTemporals < ActiveRecord::Migration
  def change
    create_table :settings_temporals do |t|
      t.string :name
      t.string :remark

      t.timestamps null: false
    end
  end
end
