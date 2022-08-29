# Zachariah Ingle C3349554 SENG4500
# frozen_string_literal: true

# Base class for a response. Subclasses should implement the #parse_body method if they return a body
class Net::TP::BaseResponse
  def self.parse(...)
    new(...)
  end

  attr_reader :body, :raw_response

  def initialize(res, strict:)
    raise Net::TP::BadResponse, "Invalid Tax response: #{res.dump}" if strict && res !~ self.class::VALID_RESPONSE_REGEX

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
