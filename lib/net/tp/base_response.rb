# frozen_string_literal: true

class Net::TP::BaseResponse
  def self.parse(res)
    new(res)
  end

  attr_reader :body, :success

  def initialize(res)
    raise Net::TP::BadResponse, "Invalid Tax response" unless res =~ self.class::VALID_RESPONSE_REGEX

    @body = res
    @success = true
  end

  def success?
    success
  end

  def valid_response_regex
    if self.class::HAS_RESPONSE_BODY & !self.class::HAS_RESPONSE_FOOTER
      # Calculate
      Regexp("^#{self.class::RESPONSE_BODY_REGEX_STRING}")
    elsif self.class::HAS_RESPONSE_BODY & self.class::HAS_RESPONSE_FOOTER
      # QUERY
      Regexp("^#{self.class::RESPONSE_BODY_REGEX_STRING}#{self.class::Request::HEADER}: OK\n$")
    else
      # TAX, STORE, BYE, END
      Regexp("^#{self.class::Request::HEADER}: OK\n$")
    end
  end
end
