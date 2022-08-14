# frozen_string_literal: true

require "pry"

class TaxProtocol
  OPERATIONS = %w[TAX STORE QUERY BYE END].freeze

  def process_input(input)
    components = input.split("\n")
    operation = components[0]

    raise ArgumentError, "Unknown operation #{operation}" unless OPERATIONS.include?(operation)

    send(operation.downcase.to_sym) + end_of_message(operation)
  end

  private

  def tax
    ""
  end

  def end_of_message(operation)
    "#{operation}: OK"
  end

  def bye
    ""
  end
end
