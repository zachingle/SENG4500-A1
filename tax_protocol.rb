# frozen_string_literal: true

require "pry"

class TaxProtocol
  OPERATIONS = %w[TAX STORE QUERY BYE END].freeze
  MAX_TAX_RULES = 10

  TaxRange = Struct.new(:range, :base, :rate, keyword_init: true) do
    def to_s
      "#{range.min} #{range.max} #{base} #{rate}"
    end
  end

  def initialize
    @tax_ranges = []
  end

  def process_request(request)
    components = request.split("\n")
    operation = components[0]

    calculate(operation) if operation =~ /^\d+$/

    return "Unknown operation #{operation}" unless OPERATIONS.include?(operation)

    send(operation.downcase.to_sym, components[1..]) + end_of_message(operation)
  end

  private

  def tax(_)
    ""
  end

  def store(components)
    lower, upper, base, rate = components.map(&:to_i)

    range = Range.new(lower, upper)
    # Check if range overlaps with stored ranges
    @tax_ranges << TaxRange.new(range:, base:, rate:)

    ""
  end

  def query(_)
    @tax_ranges.join("\n")
  end

  def end_of_message(operation)
    "#{operation}: OK"
  end

  def bye
    ""
  end
end
