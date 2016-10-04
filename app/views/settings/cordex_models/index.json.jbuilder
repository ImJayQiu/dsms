json.array!(@settings_cordex_models) do |settings_cordex_model|
  json.extract! settings_cordex_model, :id, :name, :folder, :institute, :remark
  json.url settings_cordex_model_url(settings_cordex_model, format: :json)
end
