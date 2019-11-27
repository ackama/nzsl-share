class SitemapBuilder
  def first_or_generate_basic
    Sitemap.first || Sitemap.create(xml: generate_xml(page_slugs))
  end

  def update_sitemap
    Sitemap.first.update(xml: generate_xml(page_slugs + sign_slugs))
  end

  def generate_xml(slugs)
    hostname = Rails.application.routes.default_url_options[:host]

    builder = Nokogiri::XML::Builder.new do |xml|
      xml.urlset(xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9") do
        slugs.each { |slug| xml.url { xml.loc hostname + (slug.starts_with?("/") ? slug : "/#{slug}") } }
      end
    end

    builder.to_xml
  end

  private

  def fetch_all_signs
    Sign.published
  end

  def page_slugs
    StaticController::PAGES
  end

  def sign_slugs
    fetch_all_signs.map { |sign| Rails.application.routes.url_helpers.sign_path(sign) }
  end
end
