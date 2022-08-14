# frozen_string_literal: true

require "pry"

RSpec.describe "TaxClient", type: :aruba do
  before do
    cd("../../")
    run_command("ruby tax_client.rb", exit_timeout: 1)
  end

  context "with a mocked socket" do
    it "outputs when run" do
      expect(last_command_started).to have_output(
        "A client to connect to a server which implements the Tax protocol. Type HELP for valid operations.

Enter operation: ",
      )
    end
  end
end
