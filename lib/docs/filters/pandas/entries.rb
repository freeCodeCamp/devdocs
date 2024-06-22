module Docs
  class Pandas
    class EntriesFilter < Docs::EntriesFilter

      def get_name
        at_css('h1').content
      end

      def get_type
        return 'Manual' if slug.include?('user_guide')
        return 'General utility functions' if slug.match?('option|assert|errors|types|show_versions')
        return 'Extensions' if slug.match?(/extensions|check_array/)
        return 'Style' if slug.match?(/style/)
        return 'Input/output' if slug.match?(/read|io|HDFStore/)
        return 'Series' if slug.match?(/Series/)
        return 'GroupBy' if slug.match?(/groupby|Grouper/)
        return 'DataFrame' if slug.match?(/DataFrame|frame/)
        return 'Window' if slug.match?(/window|indexers/)
        return 'Index Objects' if slug.match?(/Index|indexing/)
        return 'Data offsets' if slug.match?(/offsets?/)
        return 'Resampling' if slug.match?(/resample/)
        return 'Plotting' if slug.match?(/plotting/)
        return 'Pandas arrays' if slug.match?(/arrays?|Timestamp|Datetime|Timedelta|Period|Interval|Categorical|Dtype/)
        'General functions'
      end

    end
  end
end
