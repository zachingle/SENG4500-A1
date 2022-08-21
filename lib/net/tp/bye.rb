# frozen_string_literal: true

module Net::TP::Bye
  class Request < Net::TP::BaseRequest
    HEADER = "BYE"
  end

  class Response < Net::TP::BaseResponse
    VALID_RESPONSE_REGEX = /BYE: OK\n/
  end
end
