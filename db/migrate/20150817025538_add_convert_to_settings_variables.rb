class AddConvertToSettingsVariables < ActiveRecord::Migration
  def change
    add_column :settings_variables, :c_rate, :string
    add_column :settings_variables, :c_unit, :string
  end
end
