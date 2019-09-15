# frozen_string_literal: true

namespace :freelex do
  desc "Download a copy of freelex and save to /tmp as xml"
  task download: :environment do
    config_setup
    doc = Nokogiri::XML(http_connection.get(str_builder(:path)).body)
    File.open(str_builder(:xml), "w") { |f| doc.write_xml_to f }
  end

  desc "Parse the xml and insert into freelex table"
  task create: :environment do
    config_setup

    doc = Nokogiri::XML(File.read(str_builder(:xml)))
    data = doc.xpath("//entry").inject([]) do |arr, att|
      arr << {
        ref_id: att.attributes["id"].value.to_i,
        headword: att.children[0].text,
        updated_at: fetch_date_time,
        created_at: fetch_date_time
      }
    end

    truncate_freelex_table
    FreelexSign.insert_all(data)
  end

  desc "Delete the data from freelex table"
  task delete: :environment do
    truncate_freelex_table
  end

  private

  def fetch_date_time
    DateTime.now
  end

  def truncate_freelex_table
    ActiveRecord::Base.connection.execute("TRUNCATE #{FreelexSign.table_name} RESTART IDENTITY")
  end

  def config_setup
    hsh = YAML.safe_load(File.read("#{ENV["PWD"]}/config/freelex.yml"))
    @free = hsh["freelex"]
    @file = hsh["freelex"]["file"]
  end

  def http_connection
    Faraday.new(url: str_builder(:url)) do |faraday|
      faraday.adapter Faraday.default_adapter
    end
  end

  def str_builder(opt)
    case opt
    when :url
      "#{@free["protocol"]}#{@free["domain"]}"
    when :path
      "#{@free["path"]}#{@free["query_string"]}"
    when :xml
      "#{@file["to_disk"]}#{@file["name"]}.#{@file["ext"]}"
    else
      "noop"
    end
  end
end
