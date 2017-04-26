json.array!(@settings_obs_models) do |settings_obs_model|
  json.extract! settings_obs_model, :id, :name, :folder, :institute, :remark
  json.url settings_obs_model_url(settings_obs_model, format: :json)
end
