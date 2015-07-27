json.array!(@settings_mips) do |settings_mip|
  json.extract! settings_mip, :id, :name, :fullname, :description
  json.url settings_mip_url(settings_mip, format: :json)
end
