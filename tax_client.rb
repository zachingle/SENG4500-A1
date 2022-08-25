# frozen_string_literal: true

require "optparse"
require "pry"

require_relative "lib/net/tp"

class TaxClient
  VALID_COMMANDS = %w[help connect disconnect store query calculate shutdown exit].freeze

  def self.run
    new.run
  end

  def run
    puts "A client to connect to a server which implements the Tax protocol. Enter 'help' for valid commands."

    while (
      print "\nEnter command: "
      (command = gets.chomp.downcase)
    )
      # Check for a valid command
      unless VALID_COMMANDS.include?(command)
        puts "Invalid command '#{command}'. Enter 'help' for valid commands."
        next
      end

      puts
      send(command.to_sym) # Turn command into method call e.g. HELP -> self.help
    end
  end

  private

  attr_accessor :server, :host, :port

  def help
    puts "\nValid commands are: "
    puts "    connect:    Create a new session to a tax server."
    puts "    disconnect: Close the current session with the tax server."
    puts "    store:      Store a income range and tax rule on the tax server."
    puts "    query:      Query the tax server for stored tax scale data."
    puts "    calculate:  Send an income payable to the tax server and get the tax payable."
    puts "    shutdown:   Shutdown the current tax server."
    puts "    exit:       Exit from the client (will disconnect from server)."
  end

  def connect
    if server_connected?
      puts "Already connected to a tax server."
      return
    end

    puts "Creating a connection to a tax server."

    address = "127.0.0.1"
    print "Address (default 127.0.0.1): "
    new_address = gets.chomp
    address = new_address unless new_address.empty?

    port = 3000
    print "Port (default 3000): "
    new_port = gets.chomp
    port = new_port unless new_port.empty?

    puts "Creating new tax protocol session on #{address}:#{port}."

    @server = Net::TP.new(address:, port:)
    res = @server.tax

    puts_response(res)
  end

  def store
    return if server_connection_required?

    puts "Creating a new income range and tax rule and storing it in the server."

    print "Lower range (>= 0): "
    lower = gets.chomp.to_i

    print "Upper range (enter '~' for an open upper range): "
    upper = gets.chomp.to_i

    print "Base tax: "
    base = gets.chomp.to_i

    print "Tax rate (in cents per dollar): "
    rate = gets.chomp.to_i

    res = server.store(lower:, upper:, base:, rate:)

    puts_response(res)
  end

  def query
    return if server_connection_required?

    res = server.query
    puts_response(res)

    if res.body[:ranges].empty?
      puts "No tax ranges stored on the server"
      return
    end

    puts "Received the following tax ranges: "
    res.body[:ranges].each do |tax_range|
      puts "$#{tax_range[:lower]} - $#{tax_range[:upper]}: $#{tax_range[:base]} plus #{tax_range[:rate]}c for each dollar over #{tax_range[:lower]}"
    end
  end

  def calculate
    return if server_connection_required?

  end

  def disconnect
    return unless server_connected?

    res = @server.bye
    puts_raw_response(res)

    puts "Closed connection with server"
  end

  def shutdown
    return unless server_connected?

    res = @server.end
    puts_raw_response(res)

  end

  def exit
    disconnect

    super
  end

  private

  def server_connected?
    @server&.connected?
  end

  def server_connection_required?
    unless server_connected?
      puts "Need to run 'connect' to start a session"
      return true
    end

    false
  end

  def puts_response(res)
    puts("Response: #{res.raw_response.dump}.")
  end
end

TaxClient.run
