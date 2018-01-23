# frozen_string_literal: true

# https://noiseprotocol.org/noise.html#the-handshakestate-object
RSpec.describe Ruido::HandShake do
  subject(:hs) { described_class.create }
  describe "#initialize" do
    subject(:hs) do
      hs.new(handshake_pattern: hs, initiator: i, prologue: p, s: s, e: e, rs: rs, re: re)
    end
    context "when the handshake pattern is not valid"
    xit "derives a protocol_name" do
      # expect(hs.protocol_name).to be something
    end
    xit "stores the handshake_pattern"
    xit "stores the message_patterns"
  end
end




# IK
# Static key for initiator immediately transmitted to responder
# Static key for response known to initiator
# 
# IK(s, rs):
#       <- s
#       ...
#       -> e, es, s, ss
#       <- e, ee, se
# 
#       Initiator has initialized its static keypair (s) and the remote static public key of responder
# 
#       no premessages for initiator
#       s as premessage for responder (this is, its static public key)
# 
#       messages: e, es, s,ss (initiator)
#       messages: e, ee, se   (responder)
# 
# 
# 
# 
# 
# 
# IKpsk2 variant
# 
#    IKpsk2(s, rs):
#         <- s
#         ...
#         -> e, es, s, ss
#         <- e, ee, se, psk
