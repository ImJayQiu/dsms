class CreateSettingsNexnasaModels < ActiveRecord::Migration
	def change
		create_table :settings_nexnasa_models do |t|
			t.string :name
			t.string :folder
			t.string :institute
			t.string :remark

			t.timestamps null: false
		end
	end
end
