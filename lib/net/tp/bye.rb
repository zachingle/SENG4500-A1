# Zachariah Ingle C3349554 SENG4500
# frozen_string_literal: true

# Bye operation. Used to stop a TP session
module Net::TP::Bye
  class Request < Net::TP::BaseRequest
    HEADER = "BYE"
  end

  class Response < Net::TP::BaseResponse
    VALID_RESPONSE_REGEX = /BYE: OK\n/
  end
end
