# Zachariah Ingle C3349554 SENG4500
# frozen_string_literal: true

# End operation. Used to shutdown a TP-compliant server
module Net::TP::End
  class Request < Net::TP::BaseRequest
    HEADER = "END"
  end

  class Response < Net::TP::BaseResponse
    VALID_RESPONSE_REGEX = /END: OK\n/
  end
end
