# Zachariah Ingle C3349554 SENG4500
# frozen_string_literal: true

# Tax operation. Used to start a TP session
module Net::TP::Tax
  class Request < Net::TP::BaseRequest
    HEADER = "TAX"
  end

  class Response < Net::TP::BaseResponse
    VALID_RESPONSE_REGEX = /TAX: OK\n/
  end
end
