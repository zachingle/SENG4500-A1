# frozen_string_literal: true

require "socket"

module Net
  class TP
    class BadResponse < StandardError; end

    attr_accessor :address, :port

    def self.start(...)
      new(...).tap(&:tax)
    end

    def initialize(address:, port:)
      @address = address
      @port = port
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

    def request(operation, ...)
      raise IOError, "Need to first send a Tax request and open a socket" unless operation == Tax || @socket

      open_socket unless @socket

      @socket.puts(operation::Request.construct(...))

      operation::Response.parse(@socket.gets)
    end

    def open_socket
      @socket = TCPSocket.new(@address, @port)
    rescue Errno::ECONNREFUSED => e
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
