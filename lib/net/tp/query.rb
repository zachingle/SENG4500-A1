# Zachariah Ingle C3349554 SENG4500
# frozen_string_literal: true

# Query operation. Used to query a TP-compliant server for its stored tax rates
module Net::TP::Query
  class Request < Net::TP::BaseRequest
    HEADER = "QUERY"
  end

  class Response < Net::TP::BaseResponse
    VALID_RESPONSE_REGEX = /^(((~ \d+)|(\d+ ~)|(\d+ \d+)) \d+ \d+\n)*QUERY: OK\n$/

    private

    def parse_body(res)
      # Ignore "QUERY: OK\n" line
      tax_rates = res.split("\n")[..-2].map do |rule|
        lower, upper, base, rate = rule.split

        { lower:, upper:, base:, rate: }
      end

      { tax_rates: }
    end
  end
end
