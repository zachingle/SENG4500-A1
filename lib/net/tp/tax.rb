# frozen_string_literal: true

module Net::TP::Tax
  class Request < Net::TP::BaseRequest
    HEADER = "TAX"
  end

  class Response < Net::TP::BaseResponse
    VALID_RESPONSE_REGEX = /TAX: OK\n/
  end
end
