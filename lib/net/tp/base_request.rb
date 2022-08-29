# Zachariah Ingle C3349554 SENG4500
# frozen_string_literal: true

# Base class for a request
class Net::TP::BaseRequest
  def self.construct(...)
    new.construct(...)
  end

  def construct
    "#{self.class::HEADER}\n"
  end
end
