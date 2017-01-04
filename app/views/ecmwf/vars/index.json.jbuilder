json.array!(@ecmwf_vars) do |ecmwf_var|
  json.extract! ecmwf_var, :id, :name, :var, :remark
  json.url ecmwf_var_url(ecmwf_var, format: :json)
end
