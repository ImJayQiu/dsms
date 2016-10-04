json.array!(@settings_temporals) do |settings_temporal|
  json.extract! settings_temporal, :id, :name, :remark
  json.url settings_temporal_url(settings_temporal, format: :json)
end
