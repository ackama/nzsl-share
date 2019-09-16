# frozen_string_literal: true

namespace :freelex do
  namespace :download do
    desc "Download an entire copy of freelex and save to /tmp as xml"
    task all: :environment do
      fetch_and_save(:path, :xml)
    end

    desc "Download only the obscene copy of freelex and save to /tmp as xml"
    task obscene: :environment do
      fetch_and_save(:obscene_path, :obscene_xml)
    end
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

  def fetch_and_save(path, file)
    config_setup
    doc = Nokogiri::XML(http_connection.get(str_builder(path)).body)
    File.open(str_builder(file), "w") { |f| doc.write_xml_to f }
  end

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
      faraday.options.timeout = str_builder(:timeout).to_i
      faraday.adapter Faraday.default_adapter
    end
  end

  def str_builder(opt)
    case opt
    when :url
      "#{@free["protocol"]}#{@free["domain"]}"
    when :path
      "#{@free["path"]}#{@free["query_string"]}"
    when :obscene_path
      "#{@free["path"]}#{@free["obscene_query_string"]}"
    when :xml
      "#{@file["to_disk"]}#{@file["name"]}.#{@file["ext"]}"
    when :obscene_xml
      "#{@file["to_disk"]}#{@file["obscene_name"]}.#{@file["ext"]}"
    when :timeout
      @free["timeout"]
    else
      "noop"
    end
  end
end
