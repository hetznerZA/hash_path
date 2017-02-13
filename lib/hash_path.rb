#!/usr/bin/env ruby

##
# Fetch a value from a nested dictionary
#
# Provides methods for fetching a value from a nested dictionary (an object that implements +include?+ and +fetch+),
# using a key path expressed as a list (+Enumerable+).
#
# The key path is iterated. In each iteration, the key is looked up in the dictionary, and the value found is used
# as the dictionary for the next iteration. Lookup failure immediately returns nil.
#
# @example Indifferent hash path
#
#   require "hash_path"
#
#   dict = {
#     people: {
#       "sheldon": {
#         first_name: "Sheldon",
#         last_name: "Hearn",
#         contacts: {
#           "email": "sheldonh@starjuice",
#         }
#       },
#       "charles": {
#         first_name: "Charles",
#         last_name: "Mulder",
#       }
#     }
#   }
#
#   HashPath[dict, %w{people sheldon contacts email}] # -> "sheldonh@starjuice"
#   HashPath[dict, %w{people charles contacts email}] # -> nil
#
module HashPath

  ##
  # Fetch value from dictionary using string or symbol key path
  #
  # Each value in the path is used as a symbol or, if symbol lookup fails, a string.
  #
  # @param [Hash] hash
  #   the dictionary to apply the +path+ to.
  # @param [Array] path
  #   an ordered list of keys that implement +to_s+ and +to_sym+.
  # @return [Object] the value found at the path in the dictionary.
  # @return [nil] if any key lookup failed.
  #
  def self.indifferent(hash, path)
    path.inject(hash) do |acc, p|
      break unless acc.respond_to?(:include?) && acc.respond_to?(:fetch)
      if acc.include?(p.to_sym)
        acc.fetch(p.to_sym)
      elsif acc.include?(p.to_s)
        acc[p.to_s]
      else
        break
      end
    end
  end

  class << self
    alias_method :[], :indifferent
  end

  ##
  # Fetch value from dictionary using object key path
  #
  # Each value in the path is used as is.
  #
  # @param [Hash] hash
  #   the dictionary to apply the +path+ to.
  # @param [Array] path
  #   an ordered list of object keys.
  # @return [Object] the value found at the path in the dictionary.
  # @return [nil] if any key lookup failed.
  #
  def self.object(hash, path)
    path.inject(hash) do |acc, p|
      break unless acc.respond_to?(:include?) && acc.respond_to?(:fetch) && acc.include?(p)
      acc[p]
    end
  end

  ##
  # Fetch value from dictionary using symbol key path
  #
  # Each value in the path is used as a symbol.
  #
  # @param [Hash] hash
  #   the dictionary to apply the +path+ to.
  # @param [Array] path
  #   an ordered list of keys that implement +to_sym+.
  # @return [Object] the value found at the path in the dictionary.
  # @return [nil] if any key lookup failed.
  #
  def self.symbol(hash, path)
    object(hash, path.map(&:to_sym))
  end

  ##
  # Fetch value from dictionary using string key path
  #
  # Each value in the path is used as a string.
  #
  # @param [Hash] hash
  #   the dictionary to apply the +path+ to.
  # @param [Array] path
  #   an ordered list of keys that implement +to_s+.
  # @return [Object] the value found at the path in the dictionary.
  # @return [nil] if any key lookup failed.
  #
  def self.string(hash, path)
    object(hash, path.map(&:to_s))
  end

end
