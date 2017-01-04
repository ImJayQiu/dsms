class CreateSettingsDatasetpaths < ActiveRecord::Migration
  def change
    create_table :settings_datasetpaths do |t|
      t.string :name
      t.string :path # the folder where CDAAS will keep these datasets
      t.string :source # the original datasets
      t.string :remark

      t.timestamps null: false
    end
  end
end
