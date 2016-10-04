json.array!(@ecmwf_types) do |ecmwf_type|
  json.extract! ecmwf_type, :id, :name, :folder, :remark
  json.url ecmwf_type_url(ecmwf_type, format: :json)
end
