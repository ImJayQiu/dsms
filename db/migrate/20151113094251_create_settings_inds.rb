class CreateSettingsInds < ActiveRecord::Migration
  def change
    create_table :settings_inds do |t|
      t.string :name
      t.string :description
      t.string :remark

      t.timestamps null: false
    end
  end
end
