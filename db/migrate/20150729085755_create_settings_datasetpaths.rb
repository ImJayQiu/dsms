class CreateSettingsDatasetpaths < ActiveRecord::Migration
  def change
    create_table :settings_datasetpaths do |t|
      t.string :name
      t.string :path
      t.string :remark

      t.timestamps null: false
    end
  end
end
