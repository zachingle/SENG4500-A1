# frozen_string_literal: true

require "socket"

module Net
  class TP
    class BadResponse < StandardError; end

    def self.start(...)
      new(...).tax
    end

    def initialize(address:, port:)
      @address = address
      @port = port
    end

    def tax
      raise IOError, "TP session already started" if @socket

      request(Tax)

      self
    end

    def store(lower:, upper:, base:, rate:)
      request(Store, lower, upper, base, rate)
    end

    def query
      request(Query)
    end

    def calculate(tax_payable)
      request(Calculate, tax_payable)
    end

    def bye
      request(Bye)
      @tax_connection_established = false
    end

    def end
      request(End)
    end

    private

    def request(operation, ...)
      raise IOError, "Need to first send a Tax request" unless operation == Tax || @socket

      open_socket unless @socket

      @socket.puts(operation::Request.construct(...))

      operation::Response.parse(@socket.gets)
    end

    def tax_connection_established?
      @tax_connection_established
    end

    def open_socket
      @socket = TCPSocket.new(@address, @port)
    rescue Errno::ECONNREFUSED => e
      puts "Unable to open socket at #{@address}:#{@port}. #{e}"
      raise
    end
  end
end

require_relative "tp/base_request"
require_relative "tp/base_response"
require_relative "tp/tax"
require_relative "tp/store"
