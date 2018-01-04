require "active_record"
require "database_cleaner"

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

  #dat db stuff
  ActiveRecord::Base.establish_connection(adapter: "postgresql", database: ENV["TEST_DB"] || "unionizer_test")

  ActiveRecord::Base.connection.data_sources
  ActiveRecord::Migration.class_eval do
    drop_table :dummies
  end

  ActiveRecord::Migration.class_eval do
    create_table :dummies do |t|
      t.string :name
      t.string :type
    end
  end
end
