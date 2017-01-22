# frozen_string_literal: true

module Docs
  class EntriesFilter < Filter
    def call
      result[:entries] = entries
      doc
    end

    def entries
      entries = []
      entries << default_entry if root_page? || include_default_entry?
      entries.concat(additional_entries)
      build_entries(entries)
    end

    def include_default_entry?
      true
    end

    def default_entry
      [name]
    end

    def additional_entries
      []
    end

    def name
      return @name if defined? @name
      @name = root_page? ? nil : get_name
    end

    def get_name
      slug.to_s.gsub('_', ' ').gsub('/', '.').squish!
    end

    def type
      return @type if defined? @type
      @type = root_page? ? nil : get_type
    end

    def get_type
      nil
    end

    def path
      result[:path]
    end

    def build_entries(entries)
      entries.map do |attributes|
        build_entry(*attributes)
      end
    end

    def build_entry(name, frag = nil, type = nil)
      type ||= self.type
      path = frag ? (frag.include?('#') ? frag : "#{self.path}##{frag}") : self.path
      Entry.new(name, path, type)
    end
  end
end
