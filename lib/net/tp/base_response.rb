# frozen_string_literal: true

class Net::TP::BaseResponse
  def self.parse(res)
    new(res)
  end

  attr_reader :body, :raw_response

  def initialize(res)
    raise Net::TP::BadResponse, "Invalid Tax response: #{res.dump}" unless res =~ self.class::VALID_RESPONSE_REGEX

    @body = parse_body(res)
    @raw_response = res
    @success = true
  end

  def success?
    @success
  end

  private

  def parse_body(_)
    nil
  end
end
