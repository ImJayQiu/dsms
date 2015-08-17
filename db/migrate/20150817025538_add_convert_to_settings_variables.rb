class AddConvertToSettingsVariables < ActiveRecord::Migration
  def change
    add_column :settings_variables, :c_rate, :integer
    add_column :settings_variables, :c_unit, :string
  end
end
