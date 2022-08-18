# frozen_string_literal: true

RSpec.describe(Net::TP) do
  let(:client) { described_class.start(address: address, port: port) }
  let(:socket) { instance_spy(TCPSocket) }
  let(:address) { "127.0.0.1" }
  let(:port) { 3000 }

  before do
    allow(TCPSocket).to receive(:new).with(address, port).and_return(socket)
    allow(socket).to receive(:puts).with("TAX\n")
  end

  describe ".start" do
    before { allow(socket).to receive(:gets).and_return("TAX: OK\n") }

    context "with a valid response" do
      it "initialises a socket and returns an instance of itself" do
        expect(client).to be_an_instance_of(described_class)

        expect(socket).to have_received(:puts).with("TAX\n")
      end
    end

    context "with an invalid response" do
      before { allow(socket).to receive(:gets).and_return("TAX: bad\n") }

      it "throws a BadResponse exception" do
        expect { client }.to raise_error(Net::TP::BadResponse)
      end
    end
  end

  context "with an instance of Net::TP" do
    before do
      allow(socket).to receive(:gets).and_return("TAX: OK\n")
      client # Have to initialise the client first
      allow(socket).to receive(:puts).with(request)
      allow(socket).to receive(:gets).and_return(response)
    end

    describe "#store" do
      let(:request) { "STORE\n18201\n37000\n0\n19\n" }
      let(:response) { "STORE: OK\n" }

      it "sends a new tax rule" do
        expect(client.store(lower: 18_201, upper: 37_000, base: 0, rate: 19)).to be_success
        expect(socket).to have_received(:puts).with(request)
      end
    end
  end
end
