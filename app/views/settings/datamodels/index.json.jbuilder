json.array!(@settings_datamodels) do |settings_datamodel|
  json.extract! settings_datamodel, :id, :name, :institute, :remark
  json.url settings_datamodel_url(settings_datamodel, format: :json)
end
