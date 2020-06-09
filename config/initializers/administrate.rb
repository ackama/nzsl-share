Dir[Rails.root.join("lib", "administrate_ext", "**", "*.rb")].sort.each { |f| require f }
