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
    protocol = TaxProtocol.new

    puts "Tax server started up. Listening on port #{options[:port]}"

    loop do
      client = server.accept

      while (line = client.gets)
        # HACK: Tax Protocol doesn't define an end of message indicator so we have to just read the rest of the bytes in
        # the stream and hope the client has sent all of the message at once. This is only a problem for the server with
        # the STORE operation, and a problem for the client with the QUERY operation
        line += client.readpartial(2048) if line.start_with?("STORE")

        puts "Received: #{line.dump}"
        client.puts protocol.process_request(line)
      end

      client.close
    end
  end
end

TaxServer.new
