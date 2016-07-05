class AddInfoToUsers < ActiveRecord::Migration
  def change
    add_column :users, :research_int, :string
    add_column :users, :organization, :string
    add_column :users, :country, :string
  end
end
