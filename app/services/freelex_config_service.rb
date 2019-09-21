# frozen_string_literal: true

class FreelexConfigService < ApplicationService
  attr_reader :results

  def initialize
    @results = ApplicationService.new_results
  end

  def process
    hsh = YAML.safe_load(File.read("#{ENV["PWD"]}/config/freelex.yml"))
    results.data = build_results(hsh["freelex"], hsh["freelex"]["file"])
    results
  end

  private

  def build_results(free, file)
    {
      url: "#{free["protocol"]}#{free["domain"]}",
      path: "#{free["path"]}#{free["query_string"]}",
      obscene_path: "#{free["path"]}#{free["obscene_query_string"]}",
      xml: "#{file["to_disk"]}#{file["name"]}.#{file["ext"]}",
      obscene_xml: "#{file["to_disk"]}#{file["obscene_name"]}.#{file["ext"]}",
      timeout: free["timeout"]
    }
  end
end
