# frozen_string_literal: true

require "rbnacl"

module Ruido
  # A CipherState can encrypt and decrypt data based on its k and n variables
  class CipherState
    class << self
      def create
        new(cipher: RbNaCl::AEAD::ChaCha20Poly1305IETF)
      end
    end

    def initialize(cipher:)
      @k = :empty
      @cipher_class = cipher
      itself
    end

    attr_reader :cipher_class

    def key=(key)
      @k = key
      @n = 0
    end

    def key?
      @k != :empty
    end

    def nonce=(nonce)
      @n = nonce
    end

    # EncryptWithAd(ad, plaintext): If k is non-empty returns
    # ENCRYPT(k, n++, ad, plaintext). Otherwise returns plaintext.
    def encrypt_with_ad(ad:, plaintext:)
      return plaintext unless key?
      ciphertext = encrypt(k, n, plaintext, ad)
      send(:n=, n + 1)
      ciphertext
    end

    # DecryptWithAd(ad, ciphertext):
    # If k is non-empty returns DECRYPT(k, n++, ad, ciphertext).
    # Otherwise returns ciphertext.
    # If an authentication failure occurs in DECRYPT()
    # then n is not incremented and an error is signaled to the caller.
    def decrypt_with_ad(ad:, ciphertext:)
      return ciphertext unless key?
      plaintext = decrypt(k, n, ciphertext, ad)
      send(:n=, n + 1)
      plaintext
    rescue RbNaCl::CryptoError => e
      raise Ruido::Error, e.message
    end

    private

    attr_reader :k
    attr_accessor :n

    # these two private methods are tied to chachapoly algorithm
    # when/if I add support for AES GCM, I will need to rework this
    def encrypt(key, nonce, plaintext, ad)
      @cipher ||= @cipher_class.new(key)
      # the nonce is specific to chacha20,
      # I need a way to handle the other cipher nonce
      # https://github.com/plizonczyk/noiseprotocol/blob/bf658e6c4b8d2cdcb4dc3416f14ddae1acd01412/noise/functions.py#L86
      @cipher.encrypt("\x00" * 4 + [nonce].pack("Q"), plaintext, ad)
    end

    def decrypt(key, nonce, ciphertext, ad)
      @cipher ||= @cipher_class.new(key)
      # the nonce is specific to chacha20,
      # I need a way to handle the other cipher nonce
      # https://github.com/plizonczyk/noiseprotocol/blob/bf658e6c4b8d2cdcb4dc3416f14ddae1acd01412/noise/functions.py#L86
      @cipher.decrypt("\x00" * 4 + [nonce].pack("Q"), ciphertext, ad)
    end
  end
end
