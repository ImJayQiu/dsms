class CreateEcmwfTypes < ActiveRecord::Migration
  def change
    create_table :ecmwf_types do |t|
      t.string :name
      t.string :folder
      t.string :remark

      t.timestamps null: false
    end
  end
end
