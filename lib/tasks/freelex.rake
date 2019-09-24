# frozen_string_literal: true

namespace :freelex do
  namespace :download do
    desc "Download an entire copy of freelex and save to /tmp as xml"
    task all: :environment do
      fetch_xml_and_save(:path, :xml)
    end

    desc "Download only the obscene copy of freelex and save to /tmp as xml"
    task obscene: :environment do
      fetch_xml_and_save(:obscene_path, :obscene_xml)
    end
  end

  desc "Parse the xml and insert into freelex table"
  task seed: :environment do
    config_setup
    doc = Nokogiri::XML(File.read(@config[:xml]))
    data = doc.xpath("//entry").inject([]) do |arr, att|
      arr << fetch_freelex_values(att)
    end

    truncate_freelex_table
    FreelexSign.insert_all(data)
  end

  desc "Delete the data from freelex table"
  task delete: :environment do
    truncate_freelex_table
  end

  private

  def fetch_freelex_values(att)
    {
      id: att.xpath("headwordid").text.to_i,
      english: att.xpath("glossmain").text,
      maori: att.xpath("glossmaori").text.empty? ? nil : att.xpath("glossmaori").text,
      secondary: att.xpath("glosssecondary").text.empty? ? nil : att.xpath("glosssecondary").text,
      updated_at: fetch_date_time,
      created_at: fetch_date_time
    }
  end

  def fetch_xml_and_save(path, file)
    config_setup
    doc = Nokogiri::XML(http_connection.get(@config[path]).body)
    File.open(@config[file], "w") { |f| doc.write_xml_to f }
  end

  def fetch_date_time
    DateTime.now
  end

  def truncate_freelex_table
    ActiveRecord::Base.connection.execute("TRUNCATE #{FreelexSign.table_name} RESTART IDENTITY")
  end

  def http_connection
    Faraday.new(url: @config[:url]) do |faraday|
      faraday.options.timeout = @config[:timeout].to_i
      faraday.adapter Faraday.default_adapter
    end
  end

  def config_setup
    @config = Rails.application.config.x.freelex
  end
end
