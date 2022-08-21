# frozen_string_literal: true

module Net::TP::End
  class Request < Net::TP::BaseRequest
    HEADER = "END"
  end

  class Response < Net::TP::BaseResponse
    VALID_RESPONSE_REGEX = /END: OK\n/
  end
end
