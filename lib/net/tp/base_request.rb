# frozen_string_literal: true

class Net::TP::BaseRequest
  def self.construct(...)
    new.construct(...)
  end

  def construct
    "#{self.class::HEADER}\n"
  end
end
