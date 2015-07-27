class CreateSettingsDatamodels < ActiveRecord::Migration
  def change
    create_table :settings_datamodels do |t|
      t.string :name
      t.string :institute
      t.string :remark

      t.timestamps null: false
    end
  end
end
