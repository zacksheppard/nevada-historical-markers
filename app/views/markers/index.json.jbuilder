json.array!(@markers) do |marker|
  json.extract! marker, :id, :number, :title
  json.url marker_url(marker, format: :json)
end
