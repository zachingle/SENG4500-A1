# Zachariah Ingle C3349554 SENG4500
# frozen_string_literal: true

# Calculate operation. Used to calculate the tax payable for a given income when sent to a TP-compliant server
module Net::TP::Calculate
  class Request < Net::TP::BaseRequest
    HEADER = ""

    def construct(taxable_income)
      "#{taxable_income}\n"
    end
  end

  class Response < Net::TP::BaseResponse
    VALID_RESPONSE_REGEX = /^((TAX IS \d+(\.\d+)?)|(I DON'T KNOW \d*))\n$/
    TAX_FOUND_MESSAGE = "TAX IS "

    private

    def parse_body(res)
      if res.start_with?(TAX_FOUND_MESSAGE)
        { tax_payable: res.delete_prefix(TAX_FOUND_MESSAGE).to_i }
      else
        { tax_payable: nil }
      end
    end
  end
end
