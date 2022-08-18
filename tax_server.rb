# frozen_string_literal: true

require "optparse"
require "socket"
require "pry"

require_relative "tax_protocol"

class TaxServer
  def initialize
    options = {
      port: 3000,
    }

    OptionParser.new do |opts|
      opts.banner = "Usage: tax_server.rb [options]"

      opts.on("-p", "--port [PORT]", Integer, "Port. Default 3000") do |port|
        options[:port] = port if port
      end
    end.parse!

    server = TCPServer.new(options[:port])

    loop do
      client = server.accept
      protocol = TaxProtocol.new

      while (line = client.gets)
        puts line
        client.puts protocol.process_input(line)
      end

      client.close
    end
  end
end

TaxServer.new