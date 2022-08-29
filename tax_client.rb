# Zachariah Ingle C3349554 SENG4500
# frozen_string_literal: true

require_relative "lib/net/tp"

# Tax Client CLI. Used to interact with a Tax Protocol (TP) compliant server
class TaxClient
  VALID_COMMANDS = %w[help connect disconnect store query calculate shutdown exit].freeze

  def self.run
    new.run
  end

  def run
    puts "A CLI client to connect to a Tax Protocol (TP) compliant server. Enter 'help' for valid commands."

    loop do
      print "\nEnter command: "
      command = gets.chomp.downcase
      puts

      # Check for a valid command
      unless VALID_COMMANDS.include?(command)
        puts "Invalid command '#{command}'. Enter 'help' for valid commands."
        next
      end

      send(command.to_sym) # Call correct method given command
    end
  end

  private

  attr_accessor :server

  def help
    puts "Valid commands (with matching operation) are: "
    puts "    connect:    (TAX)    Create a new session with a TP server."
    puts "    disconnect: (BYE)    Close the current session with the TP server."
    puts "    store:      (STORE)  Store a income range and tax rule on the TP server."
    puts "    query:      (QUERY)  Query the TP server for stored tax rate data."
    puts "    calculate:  (/\\d+/)  Send an income payable to the TP server and get the tax payable."
    puts "    shutdown:   (END)    Shutdown the current TP server."
    puts "    exit:       (BYE)    Exit the client (will disconnect from the server if connected)."
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

    @server = Net::TP.new(address:, port:, debug: true, strict: false)
    server.tax
  end

  def store
    return if server_connection_required?

    puts "Creating a new income range and tax rule and storing it in the server."

    print "Lower range (>= 0): "
    lower = gets.chomp

    print "Upper range (enter '~' for an open upper range): "
    upper = gets.chomp

    print "Base tax: "
    base = gets.chomp

    print "Tax rate (in cents per dollar): "
    rate = gets.chomp

    server.store(lower:, upper:, base:, rate:)
  end

  def query
    return if server_connection_required?

    res = server.query

    if res.body[:tax_rates].empty?
      puts "No tax rates stored on the server."
      return
    end

    puts "Received the following tax rates: "
    res.body[:tax_rates].each do |tax_rate|
      line = "  $#{tax_rate[:lower]}"
      line += tax_rate[:upper] == "~" ? " and over: " : " - $#{tax_rate[:upper]}: "

      has_base = tax_rate[:base] != "0"
      has_rate = tax_rate[:rate] != "0"

      line += "$#{tax_rate[:base]}" if has_base
      line += " plus " if has_base && has_rate
      line += "#{tax_rate[:rate]}c for each dollar over $#{tax_rate[:lower].to_i - 1}" if has_rate
      line += "nil" unless has_base || has_rate

      puts line
    end
  end

  def calculate
    return if server_connection_required?

    print "Please enter an income to calculate tax for: "
    income = gets.chomp

    tax_payable = server.calculate(income).body[:tax_payable]

    if tax_payable
      puts "Tax payable is: $#{tax_payable}."
    else
      puts "No tax range found for: $#{income}."
    end
  end

  def disconnect
    return unless server_connected?

    server.bye

    puts "Closed connection with server."
  end

  def shutdown
    return unless server_connected?

    server.end

    puts "Server successfully shutdown."
  end

  def exit
    disconnect

    super
  end

  private

  def server_connected?
    server&.connected?
  end

  def server_connection_required?
    unless server_connected?
      puts "Sever connection required. Run 'connect' to start a session."
      return true
    end

    false
  end
end

TaxClient.run
