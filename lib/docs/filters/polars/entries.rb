module Docs
  class Polars
    class EntriesFilter < Docs::EntriesFilter
      # Map the leading path segment of a reference page to a human readable
      # type. The Polars reference is laid out as <section>/... under the base
      # url (e.g. dataframe/api/polars.DataFrame.count.html). Top-level members
      # (plain functions, datatypes, IO, config, ...) instead live flat under
      # api/ and are classified by name in #classify_api.
      SECTION_TYPES = {
        'dataframe'      => 'DataFrame',
        'lazyframe'      => 'LazyFrame',
        'series'         => 'Series',
        'expressions'    => 'Expressions',
        'functions'      => 'Functions',
        'selectors'      => 'Selectors',
        'datatypes'      => 'Data Types',
        'datatype_expr'  => 'Data Types',
        'config'         => 'Config',
        'io'             => 'Input/output',
        'sql'            => 'SQL',
        'exceptions'     => 'Exceptions',
        'testing'        => 'Testing',
        'catalog'        => 'Catalog',
        'metadata'       => 'Metadata',
        'schema'         => 'Schema',
        'plugins'        => 'Plugins'
      }.freeze

      def get_name
        name = at_css('h1').content.strip
        # This runs before clean_html removes the headerlink, so strip its
        # anchor character off the heading.
        name.sub! %r{\s*[#\u{00B6}]+\s*\z}, ''
        name
      end

      def get_type
        return 'Manual' if root_page?
        segment = slug.split('/').first
        return classify_api(get_name) if segment == 'api'
        SECTION_TYPES[segment] || 'Manual'
      end

      private

      # Members stored flat under api/ (top-level polars.* objects).
      def classify_api(name)
        case name
        when %r{\Apolars\.datatypes\.}       then 'Data Types'
        when %r{\Apolars\.Config\b}          then 'Config'
        when %r{\Apolars\.exceptions\.}      then 'Exceptions'
        when %r{\Apolars\.testing\.}         then 'Testing'
        when %r{\Apolars\.(api|plugins)\.}   then 'Plugins'
        when %r{\Apolars\.io\.}              then 'Input/output'
        when %r{\Apolars\.DataFrame\.}       then 'DataFrame'
        when %r{\Apolars\.LazyFrame\.}       then 'LazyFrame'
        when %r{\Apolars\.(read_|scan_|write_|from_)}, %r{\Apolars\.json_normalize\b}
          'Input/output'
        else 'Functions'
        end
      end
    end
  end
end
