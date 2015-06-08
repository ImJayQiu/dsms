json.array!(@cmip5s) do |cmip5|
  json.extract! cmip5, :id
  json.url cmip5_url(cmip5, format: :json)
end
