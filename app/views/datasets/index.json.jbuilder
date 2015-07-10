json.array!(@datasets) do |dataset|
  json.extract! dataset, :id, :name, :type1, :type2, :category, :remark
  json.url dataset_url(dataset, format: :json)
end
