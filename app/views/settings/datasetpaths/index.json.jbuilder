json.array!(@settings_datasetpaths) do |settings_datasetpath|
  json.extract! settings_datasetpath, :id, :name, :path, :remark
  json.url settings_datasetpath_url(settings_datasetpath, format: :json)
end
