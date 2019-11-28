# frozen_string_literal: true

namespace :sitemap do
  desc "Generates a sitemap from published signs and pages and caches in a signle-row database table"
  task update: :environment do
    sitemap_builder = SitemapBuilder.new
    sitemap_builder.first_or_generate_basic
    sitemap_builder.update_sitemap
  end
end
