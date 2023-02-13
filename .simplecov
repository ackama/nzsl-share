require "simplecov"
SimpleCov.start("rails") do
  add_filter("/bin/")
  add_filter("/lib/tasks/auto_annotate_models.rake")
  add_filter("/lib/tasks/coverage.rake")
  add_filter ("/spec/support/")
  add_filter ("/spec/factories/")
  add_filter ("/spec/rails_helper.rb")
  add_filter ("/spec/spec_helper.rb")
end
SimpleCov.minimum_coverage(75)
