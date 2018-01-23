# frozen_string_literal: true

# https://noiseprotocol.org/noise.html#the-cipherstate-object
RSpec.describe Ruido::CipherState do
  subject(:cipher_state) { described_class.create }

  let(:sample_key) { RbNaCl::Random.random_bytes(RbNaCl::SecretBox.key_bytes) }

  describe "::create" do
    it "returns a cipher state instance" do
      expect(cipher_state.class.create).to be_a described_class
    end
    it "returns a cipher state instance which underlying cipher is ChaCha20" do
      instance = cipher_state.class.create
      expect(instance.cipher_class).to eq(RbNaCl::AEAD::ChaCha20Poly1305IETF)
    end
  end
  describe "#key=" do
    it "sets k = key" do
      k = sample_key
      cipher_state.key = k
      expect(cipher_state.instance_variable_get(:@k)).to eq(k)
    end
    it "sets n = 0" do
      k = sample_key
      cipher_state.key = k
      expect(cipher_state.instance_variable_get(:@n)).to be_zero
    end
  end
  describe "#key?" do
    context "when k is non-empty" do
      it "returns true" do
        k = sample_key
        cipher_state.key = k
        expect(cipher_state.key?).to be true
      end
    end
    context "when k is empty" do
      it "returns false" do
        expect(cipher_state.key?).to be false
      end
    end
  end
  describe "#nonce=" do
    it "sets n = nonce" do
      n = SecureRandom.random_number(2**64 - 1)
      cipher_state.nonce = n
      expect(cipher_state.instance_variable_get(:@n)).to eq(n)
    end
  end
  describe "#encrypt_with_ad" do
    context "when k is non-empty" do
      subject(:cipher_state) do
        cs = described_class.create
        k = sample_key
        cs.key = k
        cs
      end

      it "returns encrypted (binary) data" do
        plaintext = SecureRandom.alphanumeric
        ad = SecureRandom.alphanumeric
        result = cipher_state.encrypt_with_ad(ad: ad, plaintext: plaintext)
        expect(result.encoding).to eq(Encoding::ASCII_8BIT)
      end
    end
    context "when k is empty" do
      it "returns plaintext" do
        ad = double
        plaintext = SecureRandom.alphanumeric
        result = cipher_state.encrypt_with_ad(ad: ad, plaintext: plaintext)
        expect(result).to eq(plaintext)
      end
    end
  end
  describe "#decrypt_with_ad" do
    subject(:cipher_state) do
      cs = described_class.create
      ascii_key = "O8c6NuR24F5dcegYv8n1hHqujEEOdc8+wb35b1eiVOI=\n"
      cs.key = Base64.decode64(ascii_key)
      cs.nonce = nonce
      cs
    end

    let(:nonce) { 8_879_777_544_424_164_125 }

    context "when k is non-empty" do
      let(:ad) { "tfNecuawwDFSUm2V" }

      it "returns plaintext" do
        ascii_ciphertext =
          "VBFYMBZZlCdRTZqytn7ownWxteeABrfBAEGKW/72fWAZdT2Y3HeBA+pUbQ==\n"
        ciphertext = Base64.decode64(ascii_ciphertext)
        result = cipher_state.decrypt_with_ad(ad: ad, ciphertext: ciphertext)
        expect(result).to eq("In Xanadu did Kubla Khan...")
      end
    end
    context "when k is non-empty but there is an auth error during decrypt" do
      let(:ad) { SecureRandom.alphanumeric }
      let(:ciphertext) { SecureRandom.random_bytes(48) }

      it "raises an error" do
        expected_err_msg = "Decryption failed. Ciphertext failed verification."
        expect { cipher_state.decrypt_with_ad(ad: ad, ciphertext: ciphertext) }
          .to raise_error(Ruido::Error, expected_err_msg)
      end
      it "n is not incremented" do
        begin
          cipher_state.decrypt_with_ad(ad: ad, ciphertext: ciphertext)
        rescue Ruido::Error
          expect(cipher_state.instance_variable_get(:@n)).to eq(nonce)
        end
      end
    end
    context "when k is empty" do
      subject(:cipher_state) { described_class.create }

      it "returns ciphertext" do
        ad = SecureRandom.alphanumeric
        ciphertext = SecureRandom.random_bytes
        result = cipher_state.decrypt_with_ad(ad: ad, ciphertext: ciphertext)
        expect(result).to eq(ciphertext)
      end
    end
  end
  describe "#rekey" do
    xit "sets k = REKEY(k)" do
      # not implemented yet
    end
  end
end
