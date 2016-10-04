class AddCdocmdToSettingsInds < ActiveRecord::Migration
  def change
    add_column :settings_inds, :cdocmd, :string
  end
end
