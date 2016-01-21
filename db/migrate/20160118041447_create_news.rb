class CreateNews < ActiveRecord::Migration
  def change
    create_table :news do |t|
      t.datetime :date
      t.string :title
      t.text :content
      t.string :version

      t.timestamps null: false
    end
  end
end