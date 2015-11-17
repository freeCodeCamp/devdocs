module Docs
  class TclTk
    class EntriesFilter < Docs::EntriesFilter
      #def additional_entries
      #  type = nil
      #end

      def split_slug
        slug.sub! /\.html?/, ''
        return *slug.split('/')
      end

      TYPE_MAP = {
        'TclCmd' => 'Tcl',
        'TkCmd' => 'Tk',
        'ItclCmd' => 'incr',
	'SqliteCmd' => 'tdbc',
	'TdbcCmd' => 'tdbc',
	'TdbcmysqlCmd' => 'tdbc',
	'TdbcodbcCmd' => 'tdbc',
	'TdbcpostgresCmd' => 'tdbc',
	'TdbcsqliteCmd' => 'tdbc',
	'ThreadCmd' => 'Thread',
        'UserCmd' => 'App'
      }

      def get_type
        type, name = split_slug
        type = TYPE_MAP[type] || type
	if name == 'contents' then
	    type = nil
	end
        type
      end

      def get_name
        type, name = split_slug
        name
      end

      def additional_entries
        type, name = split_slug
        if type != 'TclCmd' || name != 'library' then
          return []
        end
        # special rule for library page which contains multiple commands at once
        entries = []
        css('a > b').each do |node|
          text = node.content.strip
          id = node.parent['href'].sub /^.*#(.*)$/, '\\1'
          entries << [text, id, TYPE_MAP[type]]
        end
        return entries
      end
    end
  end
end
