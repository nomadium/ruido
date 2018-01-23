# frozen_string_literal: true

module Ruido
  # To set up communication with another peer
  class Connection
    class << self
      # to-do: delete this method
      def start
        from_name(protocol: "Noise_IKpsk2_25519_ChaChaPoly_BLAKE2s")
      end
      def from_name(protocol:)
        instance = new(protocol: protocol)
	instance.noise_protocol = Protocol.new(name: protocol)
        instance
      end
    end
    def initialize(protocol:)
      @noise_protocol = nil
      @protocol_name  = protocol
      @handshake_finished = false
      @handshake_started  = false
      @next_step = nil
    end
    attr_accessor :noise_protocol
    def initiator!
      noise_protocol.initiator = true
      next_step = self.method(:write_message)
      noise_protocol.initiator
    end
    def write_message
    end
    private
    attr_accessor :next_step
  end
end
