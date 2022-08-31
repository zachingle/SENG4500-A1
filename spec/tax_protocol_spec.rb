# frozen_string_literal: true

RSpec.describe TaxProtocol do
  let(:protocol) { described_class.new }
  let(:process_request) { protocol.process_request(request) }

  describe "store" do
    it "stores a tax rate" do
      protocol.process_request("STORE\n0\n~\n0\n0\n")

      expect(protocol.tax_rates).to eq [TaxProtocol::TaxRate.new(range: (0..), base: 0, rate: 0)]
    end

    context "with existing tax rates" do
      before do
        protocol.process_request("STORE\n0\n5000\n0\n0\n")
        protocol.process_request("STORE\n5001\n~\n0\n0\n")
      end

      it "remove tax rate if subset" do
        protocol.process_request("STORE\n0\n~\n0\n0\n")

        expect(protocol.tax_rates).to eq [TaxProtocol::TaxRate.new(range: (0..), base: 0, rate: 0)]
      end

      it "shorten tax rates" do
        protocol.process_request("STORE\n2501\n7500\n0\n0\n")

        expect(protocol.tax_rates).to eq(
          [
            TaxProtocol::TaxRate.new(range: (0..2500), base: 0, rate: 0),
            TaxProtocol::TaxRate.new(range: (2501..7500), base: 0, rate: 0),
            TaxProtocol::TaxRate.new(range: (7501..), base: 0, rate: 0),
          ],
        )
      end

      it "same tax rate rate" do
        protocol.process_request("STORE\n5001\n~\n10\n10\n")

        expect(protocol.tax_rates).to eq(
          [
            TaxProtocol::TaxRate.new(range: (0..5000), base: 0, rate: 0),
            TaxProtocol::TaxRate.new(range: (5001..), base: 10, rate: 10),
          ],
        )
      end

      it "when new tax rate starts at 0" do
        protocol.process_request("STORE\n0\n4500\n0\n0\n")

        expect(protocol.tax_rates).to eq(
          [
            TaxProtocol::TaxRate.new(range: (0..4500), base: 0, rate: 0),
            TaxProtocol::TaxRate.new(range: (4501..5000), base: 0, rate: 0),
            TaxProtocol::TaxRate.new(range: (5001..), base: 0, rate: 0),
          ],
        )
      end

      it "edge cases" do
        protocol.process_request("STORE\n5002\n~\n10\n10\n")

        expect(protocol.tax_rates).to eq(
          [
            TaxProtocol::TaxRate.new(range: (0..5000), base: 0, rate: 0),
            TaxProtocol::TaxRate.new(range: (5001..5001), base: 0, rate: 0),
            TaxProtocol::TaxRate.new(range: (5002..), base: 10, rate: 10),
          ],
        )
      end
    end

    context "assignment spec" do
      before do
        protocol.process_request("STORE\n0\n10000\n0\n0\n")
        protocol.process_request("STORE\n10001\n20000\n0\n0\n")
      end

      it "does spec stuff" do
        expect(protocol.tax_rates).to eq(
          [
            TaxProtocol::TaxRate.new(range: (0..10000), base: 0, rate: 0),
            TaxProtocol::TaxRate.new(range: (10001..20000), base: 0, rate: 0),
          ],
        )

        protocol.process_request("STORE\n9001\n18000\n0\n0\n")

        expect(protocol.tax_rates).to eq(
          [
            TaxProtocol::TaxRate.new(range: (0..9000), base: 0, rate: 0),
            TaxProtocol::TaxRate.new(range: (9001..18000), base: 0, rate: 0),
            TaxProtocol::TaxRate.new(range: (18001..20000), base: 0, rate: 0),
          ],
        )

        protocol.process_request("STORE\n1001\n19000\n0\n0\n")

        expect(protocol.tax_rates).to eq(
          [
            TaxProtocol::TaxRate.new(range: (0..1000), base: 0, rate: 0),
            TaxProtocol::TaxRate.new(range: (1001..19000), base: 0, rate: 0),
            TaxProtocol::TaxRate.new(range: (19001..20000), base: 0, rate: 0),
          ],
        )
      end
    end
  end
end
