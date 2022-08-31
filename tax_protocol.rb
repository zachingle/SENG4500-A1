# Zachariah Ingle C3349554 SENG4500
# frozen_string_literal: true

require "set"

class TaxProtocol
  OPERATIONS = %w[TAX STORE QUERY BYE END].freeze

  TaxRate = Struct.new(:range, :base, :rate, keyword_init: true) do
    def to_s
      range_end = range.end.nil? ? "~" : range.end

      "#{range.first} #{range_end} #{base} #{rate}"
    end
  end

  attr_reader :tax_rates

  def initialize
    @tax_rates = []
  end

  def process_request(request)
    components = request.split("\n")
    operation = components[0]

    return "#{calculate(operation.to_i)}\n" if operation =~ /^\d+$/

    return "Unknown operation #{operation}" unless OPERATIONS.include?(operation)

    "#{send(operation.downcase.to_sym, components[1..])}#{end_of_message(operation)}\n"
  end

  private

  def tax(_)
    ""
  end

  def store(components)
    lower, upper, base, rate = components

    upper = upper == "~" ? nil : upper.to_i
    range = Range.new(lower.to_i, upper)

    # Remove any tax ranges which are covered by the new range
    @tax_rates.reject! { |tax_rate| range.cover?(tax_rate.range) }

    # See if any tax ranges overlap and shorten them if needed
    @tax_rates.each do |tax_rate|
      tax_rate_lower = tax_rate.range.first
      tax_rate_upper = tax_rate.range.end

      # If the lower bound of the current tax rate overlaps the new rate
      tax_rate_lower = range.end + 1 if range.cover?(tax_rate.range.first)

      # if the upper bound of the current tax rate overlaps the new rate or the upper bounds are both endless
      tax_rate_upper = range.first - 1 if range.cover?(tax_rate.range.end) || (range.end.nil? && tax_rate.range.end.nil?)

      tax_rate.range = Range.new(tax_rate_lower, tax_rate_upper)
    end

    @tax_rates << TaxRate.new(range:, base: base.to_i, rate: rate.to_i)
    @tax_rates.sort_by! { |tax_rate| tax_rate.range.first }

    ""
  end

  def query(_)
    last_newline = @tax_rates.empty? ? "" : "\n"
    "#{@tax_rates.join("\n")}#{last_newline}"
  end

  def calculate(income)
    tax_rate = @tax_rates.detect { |tax_rate| tax_rate.range.cover?(income) }

    return "I DON'T KNOW #{income}" if tax_rate.nil?

    tax_payable = tax_rate.base + ((income - tax_rate.range.first) * tax_rate.rate / 100.to_f)

    "TAX IS #{tax_payable.round}"
  end

  def bye(_)
    ""
  end

  def end(_)
    ""
  end

  def end_of_message(operation)
    "#{operation}: OK"
  end
end
