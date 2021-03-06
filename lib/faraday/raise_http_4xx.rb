require 'faraday'

# @api private
module Faraday
  class Response::RaiseHttp4xx < Response::Middleware
    def self.register_on_complete(env)
      env[:response].on_complete do |response|
        case response[:status].to_i
        when 400
          raise Twitter::BadRequest, error_message(response)
        when 401
          raise Twitter::Unauthorized, error_message(response)
        when 403
          raise Twitter::Forbidden, error_message(response)
        when 404
          raise Twitter::NotFound, error_message(response)
        when 406
          raise Twitter::NotAcceptable, error_message(response)
        when 420
          raise Twitter::EnhanceYourCalm.new error_message(response), response[:response_headers]
        end
      end
    end

    def initialize(app)
      super
      @parser = nil
    end

    private

    def self.error_message(response)
      "#{response[:method].to_s.upcase} #{response[:url].to_s}: #{response[:response_headers]['status']}#{(': ' + response[:body]['error']) if response[:body] && response[:body]['error']}"
    end
  end
end
