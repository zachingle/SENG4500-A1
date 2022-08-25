# frozen_string_literal: true

module Net::TP::Query
  class Request < Net::TP::BaseRequest
    HEADER = "QUERY"
  end

  class Response < Net::TP::BaseResponse
    VALID_RESPONSE_REGEX = /^(((~ \d+)|(\d+ ~)|(\d+ \d+)) \d+ \d+\n)*QUERY: OK\n$/

    private

    def parse_body(res)
      ranges = res.split("\n")[..-2].map do |rule|
        lower, upper, base, rate = rule.split.map(&:to_i)
        { lower:, upper:, base:, rate: }
      end

      { ranges: }
    end
  end
end
