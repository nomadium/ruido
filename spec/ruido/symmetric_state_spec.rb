# frozen_string_literal: true

# https://noiseprotocol.org/noise.html#the-symmetricstate-object
RSpec.describe Ruido::SymmetricState do
  subject(:sym_state) { described_class.create }

  describe "#initialize" do
    context "when protocol_name is > to Ruido::HASHLEN bytes in length" do
      it "h is equal to HASH(protocol_name)" do
        # protocol_name = "Noise_IKpsk2_25519_ChaChaPoly_BLAKE2s"
        ascii_hashed_protocol_name =
          "XF6YYYI277FOtJZDVGmn2V+LCuzDy03Qe6wVAE3KRCs=\n"
        expected_h = Base64.decode64(ascii_hashed_protocol_name)
        expect(sym_state.instance_variable_get(:@h)).to eq(expected_h)
      end
      it "h is a string with Ruido::HASHLEN bytes" do
        expect(sym_state.instance_variable_get(:@h).length)
          .to eq(Ruido::HASHLEN)
      end
    end
    context "when protocol_name is ≤ to Ruido::HASHLEN bytes in length" do
      subject(:sym_state) { described_class.new(protocol_name: protocol_name) }

      let(:protocol_name) { "Noise_Foobar" }

      it "h is equal to protocol_name plus zero bytes to make HASHLEN bytes" do
        null_bytes = "\x00" * (Ruido::HASHLEN - protocol_name.length)
        expected_h = protocol_name + null_bytes
        expect(sym_state.instance_variable_get(:@h)).to eq(expected_h)
      end

      it "h is a string with Ruido::HASHLEN bytes" do
        expect(sym_state.instance_variable_get(:@h).length)
          .to eq(Ruido::HASHLEN)
      end
    end
    it "sets ck = h" do
      ck = sym_state.instance_variable_get(:@ck)
      h = sym_state.instance_variable_get(:@h)
      expect(ck).to eq(h)
    end
    it "initializes its internal cipher state with an empty key" do
      expect(sym_state.cipher_state.key?).to be false
    end
  end
end
