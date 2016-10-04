json.array!(@settings_experiments) do |settings_experiment|
  json.extract! settings_experiment, :id, :name, :fullname, :description
  json.url settings_experiment_url(settings_experiment, format: :json)
end
