# frozen_string_literal: true

require "set"
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

    # Check to see if existing range exists with exact same lower and upper
    existing_tax_range = @tax_ranges.detect { |r| r.range == range }

    if existing_tax_range
      existing_tax_range.base = base
      existing_tax_range.rate = rate
      return ""
    end

    # See if any tax ranges overlap and shorten them if needed
    @tax_ranges.each do |r|
      new_range = r.range.to_a - range.to_a

      r.range = Range.new(new_range[0], new_range[-1]) if new_range.length.positive?
    end

    # Remove any tax ranges which are a subset of the new range
    @tax_ranges.reject! { |r| r.range.to_set.subset?(range.to_set) }

    @tax_ranges << TaxRange.new(range:, base:, rate:)
    @tax_ranges.sort_by! { |r| r.range.min }

    ""
  end

  def query(_)
    "#{@tax_ranges.join("\n")}\n"
  end

  def end_of_message(operation)
    "#{operation}: OK"
  end

  def bye
    ""
  end
end
