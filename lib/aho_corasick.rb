require "ffi"

module AhoCorasick
  module C
    extend FFI::Library
    ffi_lib "ext/ahocorasick.bundle"

    class MatchStruct < FFI::Struct
      layout :pattern, :pointer,
             :position, :long,
             :number, :uint
    end

    class PatternStruct < FFI::Struct
      layout :string, :pointer,
             :length, :uint,
             :representative, :pointer
    end

    class TextStruct < FFI::Struct
      layout :string, :pointer,
             :length, :uint
    end

    callback :match_callback, [:pointer, :pointer], :int

    attach_function :ac_automata_init, [:match_callback], :pointer
    attach_function :ac_automata_add,  [:pointer, :pointer], :int
    attach_function :ac_automata_finalize, [:pointer], :void
    attach_function :ac_automata_search, [:pointer, :pointer, :pointer], :int
    attach_function :ac_automata_reset, [:pointer], :void
    attach_function :ac_automata_release, [:pointer], :void
    attach_function :ac_automata_display, [:pointer, :char], :void
  end

  class Search
    include C

    Match = Struct.new(:representative, :matched, :position)

    attr_reader :trie

    def initialize(dictionary)
      @matches = []
      @callback = lambda do |match_pointer, void_pointer|
        match = MatchStruct.new(match_pointer)
        pattern = PatternStruct.new(match[:pattern])
        @matches << Match.new(pattern[:representative].get_string(0),
                              pattern[:string].get_string(0),
                              match[:position] - pattern[:length])
        return 0
      end
      @trie = ac_automata_init(@callback)

      dictionary.each do |key, values|
        values.each {|value| add(key, value) }
      end

      finalize
    end

    def matches(string)
      @matches.clear
      reset

      text = TextStruct.new
      text[:string] = string_pointer(string)
      text[:length] = string.length

      ac_automata_search(trie, text.pointer, nil)

      @matches
    end

    private

    def add(representative, string)
      pattern = PatternStruct.new
      pattern[:string] = string_pointer(string)
      pattern[:length] = string.length
      pattern[:representative] = string_pointer(representative)

      ac_automata_add(trie, pattern.pointer)
    end

    def finalize
      ac_automata_finalize(trie)
    end

    def reset
      ac_automata_reset(trie)
    end

    def release
      ac_automata_release(trie)
    end

    def display
      ac_automata_display(trie, ?s.ord)
    end

    def string_pointer(string)
      FFI::MemoryPointer.from_string(string.to_s)
    end
  end
end
