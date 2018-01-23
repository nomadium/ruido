require "rbnacl"

module Ruido
  # A SymmetricState object contains a CipherState plus the following variables:
  # - ck: A chaining key of HASHLEN bytes.
  # - h: A hash output of HASHLEN bytes.
  # https://noiseprotocol.org/noise.html#the-symmetricstate-object
  class SymmetricState
    class << self
      def create
        new(protocol_name: "Noise_IKpsk2_25519_ChaChaPoly_BLAKE2s")
      end

      # This method doesn't belong here
      #
      # HMAC-HASH(key, data): Applies HMAC as specified in RFC 2104 using
      # the HASH() function.
      def hmac_hash(key:, data:)
        RbNaCl::Hash.blake2b(data, key: key, digest_size: 32)
      end

      # This method doesn't belong here
      #
      # HKDF(chaining_key, input_key_material, num_outputs):
      # Returns a pair or triple of byte sequences each of length HASHLEN,
      # depending on whether num_outputs is two or three
      def hkdf(chaining_key:, input_key_material:, num_outputs:)
        err_msg = "Invalid outputs number, only 2 or 3 are supported"
        raise Error, err_msg if num_outputs != 2 && num_output != 3

        temp_key = hmac_hash(chaining_key, input_key_material)
        output1 = hmac_hash(temp_key, "\x01")
        output2 = hmac_hash(temp_key, output1 + "\x02")
        # maybe is better to return a set
        return [output1, output2] if num_outputs == 2

        output3 = hmac_hash(temp_key, output2 + "\x03")
        # maybe is better to return a set
        [output1, output2, output3]
      end
    end

    def initialize(protocol_name:)
      if protocol_name.length <= HASHLEN
        null_bytes = "\x00" * (HASHLEN - protocol_name.length)
        h_parts = { proto_name: protocol_name, null_bytes: null_bytes }
        @h = format("%<proto_name>s%<null_bytes>s", h_parts)
      else
        # don't hardcode this
        @h = RbNaCl::Hash.blake2b(protocol_name, digest_size: 32)
      end
      @ck = @h
      @cipher_state = CipherState.create
    end

    attr_reader :cipher_state

    # to-do: implement
    # def mix_key(input_key_material:)
    # end

    require "pry"
    def mix_hash(data:)
      binding.pry
      @h = RbNaCl::Hash.blake2b(h + data, digest_size: 32)
    end

    private

    attr_accessor :h
  end
end
