# frozen_string_literal: true

module Ruido
  class Protocol
    # delete this later
    class << self
      def start
        new(name: "Noise_IKpsk2_25519_ChaChaPoly_BLAKE2s")
      end
    end

    def initialize(name:)
      @name = name
      @initiator = false
      _parse_protocol_name
    end

    attr_accessor :initiator

    private

    attr_reader :name

    def _parse_protocol_name
      raise Error, "Unsupported protocol: #{name}" \
        if name != "Noise_IKpsk2_25519_ChaChaPoly_BLAKE2s"

      family, pattern, dh, cipher, hash = name.split("_")
      raise Error, "Invalid protocol: #{name}" unless family == "Noise"

#       patterns_map = {
#         pattern_IK: PatternIK
#       }
# 
#       mapped_data = {
#         "pattern" => patterns_map[:pattern_IK],
#         "dh"      =>       dh_map["25519"],
#         "cipher"  =>   cipher_map["ChaChaPoly"],
#         "hash"    =>     hash_map["BLAKE2s"],
#         "keypair" =>  keypair_map["25519"]
#       }
#       modifiers = ["psk2"]
    end
  end
end

