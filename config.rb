require 'data_mapper'
DataMapper::Model.raise_on_save_failure = true
DataMapper.setup :default, "sqlite://#{Dir.pwd}/db"
Dir['./models/*'].each { |model| require model }
DataMapper.finalize
$environment = :development
