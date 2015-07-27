json.array!(@settings_ensembles) do |settings_ensemble|
  json.extract! settings_ensemble, :id, :name, :fullname, :description
  json.url settings_ensemble_url(settings_ensemble, format: :json)
end
