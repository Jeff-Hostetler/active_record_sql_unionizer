Gem::Specification.new do |s|
  s.name        = 'active_record_sql_unionizer'
  s.version     = '0.0.1'
  s.date        = '2017-12-22'
  s.summary     = "Union for ActiveRecord::Relation and SQL string queries"
  s.description = "Union for ActiveRecord::Relation and SQL string queries. Fam."
  s.authors     = ["Jeff Hostetler"]
  s.email       = 'superfake@example.com'
  s.files       = ["lib/active_record_sql_unionizer.rb"]
  s.homepage    = 'http://rubygems.org/gems/active_record_sql_unionizer'
  s.license     = 'MIT'

  s.add_dependency "activerecord", "~> 4.0"

  s.add_development_dependency "pg",   "~> 0.20"
  s.add_development_dependency "rspec",   "~> 3.4"
  s.add_development_dependency "database_cleaner", "~> 1.6"
end
