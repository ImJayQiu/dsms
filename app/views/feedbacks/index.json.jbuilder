json.array!(@feedbacks) do |feedback|
  json.extract! feedback, :id, :title, :content, :answer, :user
  json.url feedback_url(feedback, format: :json)
end
