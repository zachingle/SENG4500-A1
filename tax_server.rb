# Zachariah Ingle C3349554 SENG4500

# frozen_string_literal: true

require "optparse"
require "socket"

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
      session_started = false

      while (msg = client.gets)
        if !session_started && msg != "TAX\n"
          client.puts "Need to send 'TAX\\n' to start session"
          break
        else
          session_started = true
        end

        if msg.start_with?("STORE")
          4.times do
            msg += client.gets
          end
        end

        puts "Received: #{msg.dump}"

        response = protocol.process_request(msg)
        puts "Sent: #{response.dump}"
        client.write response

        break if msg == "BYE\n"

        if msg == "END\n"
          client.close
          exit
        end
      end

      client.close
    end
  end
end

TaxServer.new
