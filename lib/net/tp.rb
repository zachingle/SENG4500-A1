# Zachariah Ingle C3349554 SENG4500
# frozen_string_literal: true

require "socket"

module Net
  # Tax Protocol (TP) Client. Operations are public methods on the client (e.g TAX => #tax, STORE => #store)
  class TP
    class BadResponse < StandardError; end

    attr_accessor :address, :port

    # Helper method that returns a TP client that is already connected
    def self.start(...)
      new(...).tap(&:tax)
    end

    def initialize(address:, port:, debug: false, strict: false)
      @address = address
      @port = port
      @debug = debug   # To see raw request and response strings
      @strict = strict # For ensuring valid responses
    end

    def tax
      raise IOError, "TP session already started" if @socket

      request(Tax)
    end

    def store(lower:, upper:, base:, rate:)
      request(Store, lower, upper, base, rate)
    end

    def query
      request(Query)
    end

    def calculate(taxable_income)
      request(Calculate, taxable_income)
    end

    def bye
      response = request(Bye)
      close_socket

      response
    end

    def end
      response = request(End)
      close_socket

      response
    end

    def connected?
      @socket && !@socket.closed?
    end

    private

    # Takes an operation constant (e.g Tax, Store, etc) and optional args. Requests operation and the parses response
    def request(operation, ...)
      raise IOError, "Need to first send a Tax request and open a socket" unless operation == Tax || @socket

      open_socket unless @socket

      request = operation::Request.construct(...)
      puts "[DEBUG] Sent: #{request.dump}" if @debug
      @socket.write(request)

      response = @socket.gets
      # Need to do this as the Query response is multiple line
      response += @socket.gets while operation == Query && !response.end_with?("QUERY: OK\n")

      puts "[DEBUG] Received: #{response.dump}" if @debug

      operation::Response.parse(response, strict: @strict)
    end

    def open_socket
      @socket = TCPSocket.new(@address, @port)
    rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH, SocketError, Errno::EADDRNOTAVAIL => e
      puts "Unable to open socket at #{@address}:#{@port}. #{e}"
      raise
    end

    def close_socket
      @socket.close
    end
  end
end

require_relative "tp/base_request"
require_relative "tp/base_response"
require_relative "tp/tax"
require_relative "tp/store"
require_relative "tp/query"
require_relative "tp/calculate"
require_relative "tp/bye"
require_relative "tp/end"
