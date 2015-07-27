json.array!(@settings_variables) do |settings_variable|
  json.extract! settings_variable, :id, :name, :fullname, :description
  json.url settings_variable_url(settings_variable, format: :json)
end
