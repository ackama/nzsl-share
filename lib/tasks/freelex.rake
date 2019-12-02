# frozen_string_literal: true

namespace :freelex do
  desc "Meta-task to download and load all signs from Freelex"
  task seed: %w[freelex:download:all freelex:download:obscene freelex:load freelex:exclude_obscene]

  namespace :download do
    desc "Download an entire copy of freelex and save to /tmp as xml"
    task all: :environment do
      puts "Fetching all"
      fetch_xml_and_save(:path, :xml)
    end

    desc "Download only the obscene copy of freelex and save to /tmp as xml"
    task obscene: :environment do
      puts "Fetching obscene"
      fetch_xml_and_save(:obscene_path, :obscene_xml)
    end
  end

  desc "Parse the xml and insert into freelex table"
  task load: :environment do
    puts "Loading all"
    doc = Nokogiri::XML(File.read(FREELEX_CONFIG[:xml]))
    data = doc.xpath("//entry").map(&method(:fetch_freelex_values))
    ids = FreelexSign.upsert_all(data, unique_by: :headword_id, returning: %i[headword_id])
    FreelexSign.where.not(headword_id: ids).destroy_all
  end

  desc "Exclude obscene values based on headword ID"
  task exclude_obscene: :environment do
    puts "Excluding obscene"
    doc = Nokogiri::XML(File.read(FREELEX_CONFIG[:obscene_xml]))
    ids = doc.xpath("//entry/headwordid").map(&:text)
    FreelexSign.where(headword_id: ids).destroy_all
  end

  private

  def fetch_freelex_values(att)
    time = Time.zone.now
    {
      headword_id: att.xpath("headwordid").text.to_i,
      word: att.xpath("glossmain").text,
      maori: att.xpath("glossmaori").text.empty? ? nil : att.xpath("glossmaori").text,
      secondary: att.xpath("glosssecondary").text.empty? ? nil : att.xpath("glosssecondary").text,
      tags: att.xpath("HEADWORDTAGS").text.empty? ? [] : att.xpath("HEADWORDTAGS").text.split(/,/),
      created_at: time,
      updated_at: time
    }
  end

  def fetch_xml_and_save(path, file)
    doc = Nokogiri::XML(http_connection.get(FREELEX_CONFIG[path]).body)
    File.open(FREELEX_CONFIG[file], "w") { |f| doc.write_xml_to f }
  end

  def http_connection
    Faraday.new(url: FREELEX_CONFIG[:url]) do |faraday|
      faraday.options.timeout = FREELEX_CONFIG[:timeout].to_i
      faraday.adapter Faraday.default_adapter
    end
  end
end
