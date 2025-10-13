Scalar.setup do |config|
  config.specification = File.read(Rails.root.join('doc/openapi.yaml'))
end