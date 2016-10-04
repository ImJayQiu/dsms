json.array!(@settings_inds) do |settings_ind|
  json.extract! settings_ind, :id, :name, :description, :remark
  json.url settings_ind_url(settings_ind, format: :json)
end
