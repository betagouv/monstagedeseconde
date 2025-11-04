Scalar.setup do |config|
  config.specification = File.read(Rails.root.join('doc/api/v2/openapi.yaml'))
end