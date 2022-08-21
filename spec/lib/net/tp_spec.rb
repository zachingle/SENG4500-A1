# frozen_string_literal: true

RSpec.describe(Net::TP) do
  let(:client) { described_class.start(address:, port:) }
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

  context "with an instance of Net::TP that is connected" do
    before do
      # Have to initialise the client/connection first
      allow(socket).to receive(:gets).and_return("TAX: OK\n")
      client

      allow(socket).to receive(:puts).with(request)
      allow(socket).to receive(:gets).and_return(response)
      allow(socket).to receive(:close)
    end

    describe "#store" do
      let(:request) { "STORE\n18201\n37000\n0\n19\n" }
      let(:response) { "STORE: OK\n" }
      let(:client_response) { client.store(lower: 18_201, upper: 37_000, base: 0, rate: 19) }

      it "sends a new tax rule" do
        expect(client_response).to be_success

        expect(socket).to have_received(:puts).with(request)
      end
    end

    describe "#query" do
      let(:request) { "QUERY\n" }
      let(:response) { "18201 37000 0 19\nQUERY: OK\n" }
      let(:client_response) { client.query }

      it "returns tax rule" do
        expect(client_response).to be_success
        expect(client_response.body).to eq([{ lower: 18_201, upper: 37_000, base: 0, rate: 19 }])

        expect(socket).to have_received(:puts).with(request)
      end
    end

    describe "#calculate" do
      let(:request) { "30000\n" }
      let(:response) { "TAX IS 2241.81\n" }
      let(:client_response) { client.calculate(30_000) }

      it "returns a tax payable" do
        expect(client_response).to be_success
        expect(client_response.body).to eq(tax_payable: 2241.81)

        expect(socket).to have_received(:puts).with(request)
      end

      describe "when no tax range exists" do
        let(:response) { "I DON'T KNOW 30000\n" }

        it "returns nil" do
          expect(client_response).to be_success
          expect(client_response.body).to eq(tax_payable: nil)

          expect(socket).to have_received(:puts).with(request)
        end
      end
    end

    describe "#bye" do
      let(:request) { "BYE\n" }
      let(:response) { "BYE: OK\n" }
      let(:client_response) { client.bye }

      it "sends a new tax rule" do
        expect(client_response).to be_success
        expect(client_response.body).to be_nil

        expect(socket).to have_received(:close)
        expect(socket).to have_received(:puts).with(request)
      end
    end

    describe "#end" do
      let(:request) { "END\n" }
      let(:response) { "END: OK\n" }
      let(:client_response) { client.end }

      it "sends a new tax rule" do
        expect(client_response).to be_success
        expect(client_response.body).to be_nil

        expect(socket).to have_received(:close)
        expect(socket).to have_received(:puts).with(request)
      end
    end
  end
end
