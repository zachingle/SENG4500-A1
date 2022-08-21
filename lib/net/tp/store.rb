# frozen_string_literal: true

module Net::TP::Store
  class Request < Net::TP::BaseRequest
    HEADER = "STORE"

    def construct(*args)
      "#{self.class::HEADER}\n#{args.join("\n")}"
    end
  end

  class Response < Net::TP::BaseResponse
    VALID_RESPONSE_REGEX = /STORE: OK\n/
  end
end
