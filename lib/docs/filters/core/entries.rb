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
      if frag.present? && frag.include?('#')
        path = frag
        # TODO: What should `url` get changed to?
        url = current_url
      else
        hash_frag = frag ? "##{frag}" : ''
        path = "#{self.path}#{hash_frag}"
        url = "#{current_url}#{hash_frag}"
      end
      Entry.new(name, path, type, url)
    end
  end
end
