json.array!(@news) do |news|
  json.extract! news, :id, :date, :title, :content, :version
  json.url news_url(news, format: :json)
end
