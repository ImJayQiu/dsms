class CreateCmip5s < ActiveRecord::Migration
  def change
    create_table :cmip5s do |t|

      t.timestamps null: false
    end
  end
end
