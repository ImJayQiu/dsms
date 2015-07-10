class CreateDatasets < ActiveRecord::Migration
  def change
    create_table :datasets do |t|
      t.string :name
      t.string :type1
      t.string :type2
      t.string :category
      t.string :remark

      t.timestamps null: false
    end
  end
end
