json.array!(@settings_nexnasa_models) do |settings_nexnasa_model|
  json.extract! settings_nexnasa_model, :id, :name, :folder, :institute, :remark
  json.url settings_nexnasa_model_url(settings_nexnasa_model, format: :json)
end
