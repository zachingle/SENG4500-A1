# frozen_string_literal: true

require "optparse"
require "socket"
require "pry"

class TaxClient
  VALID_OPERATIONS = %w[help tax store query calculate bye end exit].freeze

  def self.run
    new.run
  end

  def run
    puts "A client to connect to a server which implements the Tax protocol. Enter 'help' for valid operations."

    while (
      print "\nEnter operation: "
      (operation = gets.chomp.downcase)
    )
      # Check for a valid operation
      unless VALID_OPERATIONS.include?(operation)
        puts "\nInvalid operation '#{operation}'. Enter 'help' for valid operations."
        next
      end

      send(operation.to_sym) # Turn operation into method call e.g. HELP -> self.help
    end
  end

  private

  attr_accessor :server, :host, :port

  def help
    puts "\nValid operations are: "
    puts "    help:       List all operations and their use."
    puts "    connect:    Create a socket to a tax server."
    puts "    disconnect: Close the current session with the tax server."
    puts "    store:      Store a income range and tax rule on the tax server."
    puts "    query:      Query the tax server for stored tax scale data."
    puts "    calculate:  Send an income payable to the tax server and get the tax payable."
    puts "    disconnect: Close the current session with the tax server."
    puts "    shutdown:   Shutdown the current tax server."
    puts "    exit:       Exit from the client (will close socket with server if created)."
  end

  def tax
    unless server_closed?
      puts "A socket to a tax server has already been created"
      return
    end

    puts "\nCreating a socket to a tax server"

    host = "127.0.0.1"
    port = 3000

    print "Host (default 127.0.0.1): "
    new_host = gets.chomp
    @host = new_host unless new_host.empty?

    print "Port (default 3000): "
    new_port = gets.chomp
    @port = new_port unless new_port.empty?

    puts "Creating socket on #{host}:#{port} and sending 'TAX'"

    begin
      @server = TCPSocket.new(host, port)
    rescue Errno::ECONNREFUSED
      puts "No open socket on #{host}:#{port}"
      return
    end

    server.puts("TAX\n")

    response = server.gets
    puts "Received: #{response.dump}"

    if response == "TAX: OK\n"
      puts "Socked sucessfully created with tax server"
    else
      puts "Invalid response received from tax server"
    end
  end

  def store
    return if server_closed?

    puts "\nCreating a new income range and tax rule and sending it to the server"

    print "Lower range (> 0): "
    lower_range = gets.chomp

    print "Upper range (enter '~' for an open upper range): "
    upper_range = gets.chomp

    print "Base tax: "
    base_tax = gets.chomp

    print "Tax rate (in cents per dollar): "
    tax_rate = gets.chomp

    server.puts ("STORE\n#{lower_range}\n#{upper_range}\n#{base_tax}\n#{tax_rate}\n")

    response = server.gets
    puts "Received: #{response.dump}"
  end

  def bye
    return if server_closed?

    server.puts("BYE\n")

    response = server.gets
    puts "Received: #{response.dump}"

    server.close
    puts "Closed connection with server"
  end

  def end
    return unless server
  end

  def exit
    bye

    super
  end

  def server_closed?
    puts "No server socket created"
    server.nil? || server.closed?
  end
end

TaxClient.run
