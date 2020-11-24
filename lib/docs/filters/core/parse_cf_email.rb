# frozen_string_literal: true

module Docs
  class ParseCfEmailFilter < Filter
    def call
      css('.__cf_email__').each do |node|
        str = node['data-cfemail']
        mask = "0x#{str[0..1]}".hex | 0
        result = ''

        str.chars.drop(2).each_slice(2) do |slice|
          result += "%" + "0#{("0x#{slice.join}".hex ^ mask).to_s(16)}"[-2..-1]
        end

        node.replace(URI.decode_www_form_component(result))
      end

      doc
    end
  end
end
