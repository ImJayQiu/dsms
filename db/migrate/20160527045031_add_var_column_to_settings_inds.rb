class AddVarColumnToSettingsInds < ActiveRecord::Migration
  def change
    add_column :settings_inds, :var, :string
  end
end
