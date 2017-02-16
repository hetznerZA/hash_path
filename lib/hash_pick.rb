#!/usr/bin/env ruby

##
# Fetch a value from a nested dictionary
#
# Provides methods for fetching a value from a nested dictionary
# (an object structure whose root and branch nodes are +Enumerable+ and implement +[]+),
# using a key path expressed as a list (an +Enumerable+ object whose +each+ method yields a path key).
#
# The key path is iterated. In each iteration, the key is looked up in the dictionary, and the value found is used
# as the dictionary for the next iteration. Lookup failure immediately returns nil.
#
# @example Indifferent hash path
#
#   require "hash_pick"
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
#   HashPick[dict, %w{people sheldon contacts email}] # -> "sheldonh@starjuice"
#   HashPick[dict, %w{people charles contacts email}] # -> nil
#
module HashPick

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
  # @raise [ArgumentError] if +hash+ isn't a dictionary.
  # @raise [ArgumentError] if +path+ isn't a list.
  # @raise [ArgumentError] if any key in +path+ is +nil+.
  #
  def self.indifferent(hash, path)
    assert_non_nil_path_keys(path)

    pick(hash, path) do |acc, p|
      acc[p.to_sym].nil? ? acc[p.to_s] : acc[p.to_sym]
    end
  end

  ##
  # General form of hash path iteration
  #
  # Passes to +block+, the dictionary and hash key for each iteration of the hash path, using
  # the return value of the block as the dictionary for the next iteration, or in the case of
  # the last iteration, as the return value. If the block returns a non-dictionary in any but
  # the last iteration, or if the block throws +:break+, iteration is aborted and +nil+ is
  # returned.
  #
  # @example Complex hash path semantics
  #
  #   require "hash_pick"
  #
  #   dict = {
  #     live: true,
  #     sheldon: {
  #       live: true,
  #       first_name: "Sheldon",
  #       last_name: "Hearn",
  #     },
  #     charles: {
  #       first_name: "Charles",
  #       last_name: "Mulder",
  #     }
  #   }
  #
  #   HashPick.pick(dict, [:sheldon, :first_name]) { |p, k| p[k] if p[:live] }
  #   # => "Sheldon"
  #
  #   HashPick.pick(dict, [:charles, :first_name]) { |p, k| p[k] if p[:live] }
  #   # => nil
  #
  # @param [Hash] hash
  #   the dictionary to apply the +path+ to.
  # @param [Array] path
  #   an ordered list of path keys.
  # @return [Object] the value of the last iteration.
  # @return [nil] if +block+ throws +:break+ in any iteration.
  # @return [nil] if +block+ returns a non-dictionary for any but the last iteration.
  # @raise [ArgumentError] if +hash+ isn't a dictionary.
  # @raise [ArgumentError] if +path+ isn't a list.
  #
  def self.pick(hash, path, &block)
    assert_dictionary(hash)
    assert_enumerable_path(path)
    catch(:break) do
      path.inject(hash) do |acc, p|
        break unless dictionary?(acc)
        block.call(acc, p)
      end
    end
  end

  class << self
    alias_method :[], :indifferent

    private

    def assert_dictionary(hash)
      raise ArgumentError.new("hash is not a dictionary") unless dictionary?(hash)
    end

    def dictionary?(hash)
      hash.is_a?(Enumerable) and hash.respond_to?(:[])
    end

    def assert_non_nil_path_keys(path)
      raise ArgumentError.new("nil key in path") if path.any? { |p| p.nil? }
    end

    def assert_enumerable_path(path)
      raise ArgumentError.new("path is not enumerable") unless path.is_a?(Enumerable)
    end

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
  # @raise [ArgumentError] if +hash+ isn't a dictionary.
  # @raise [ArgumentError] if +path+ isn't a list.
  #
  def self.object(hash, path)
    pick(hash, path) { |acc, p| acc[p] }
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
  # @raise [ArgumentError] if +hash+ isn't a dictionary.
  # @raise [ArgumentError] if +path+ isn't a list.
  # @raise [ArgumentError] if any key in +path+ is +nil+.
  #
  def self.symbol(hash, path)
    assert_non_nil_path_keys(path)
    pick(hash, path) { |acc, p| acc[p.to_sym] }
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
  # @raise [ArgumentError] if +hash+ isn't a dictionary.
  # @raise [ArgumentError] if +path+ isn't a list.
  # @raise [ArgumentError] if any key in +path+ is +nil+.
  #
  def self.string(hash, path)
    assert_non_nil_path_keys(path)
    pick(hash, path) { |acc, p| acc[p.to_s] }
  end

end
