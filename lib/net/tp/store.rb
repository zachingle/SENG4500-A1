# Zachariah Ingle C3349554 SENG4500
# frozen_string_literal: true

# Store operation. Used to store a new tax rate on a TP-compliant server
module Net::TP::Store
  class Request < Net::TP::BaseRequest
    HEADER = "STORE"

    def construct(*args)
      "#{self.class::HEADER}\n#{args.join("\n")}\n"
    end
  end

  class Response < Net::TP::BaseResponse
    VALID_RESPONSE_REGEX = /STORE: OK\n/
  end
end
