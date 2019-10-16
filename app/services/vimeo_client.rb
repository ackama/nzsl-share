require "ostruct"

class VimeoClient
  class Error < StandardError; end

  def initialize(configuration=nil)
    @configuration = configuration || Rails.application.config_for(:vimeo)
    @connection = Faraday.new(url: @configuration[:host], headers: { user_agent: user_agent }) do |conn|
      conn.response :logger, logger: Rails.logger if @configuration[:debug]
      conn.response :json, parser_options: { object_class: OpenStruct }
      conn.response :raise_error
      conn.token_auth(@configuration[:access_token])

      yield conn if block_given?
    end
  end

  %i[get post patch put delete].each do |verb|
    define_method(:"raw_#{verb}") do |*args|
      @connection.public_send(verb, *args)
    rescue Faraday::Error
      raise Error
    end

    define_method(verb) do |*args|
      public_send("raw_#{verb}", *args).body
    end
  end

  def user_agent
    @configuration.fetch(:user_agent, "NZSL Share #{Rails.application.config.version}")
  end
end
