class CreateEcmwfVars < ActiveRecord::Migration
  def change
    create_table :ecmwf_vars do |t|
      t.string :name
      t.string :var
      t.string :remark

      t.timestamps null: false
    end
  end
end
