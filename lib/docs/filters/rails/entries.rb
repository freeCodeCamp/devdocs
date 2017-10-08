module Docs
  class Rails
    class EntriesFilter < Docs::Rdoc::EntriesFilter
      TYPE_BY_NAME_MATCHES = {
        /Assertions|::Test|Fixture/                          => 'Testing',
        /\AActiveRecord.+mysql/i                             => 'ActiveRecord/MySQL',
        /\AActiveRecord.+postgresql/i                        => 'ActiveRecord/PostgreSQL',
        /\AActiveRecord.+sqlite/i                            => 'ActiveRecord/SQLite',
        /\AActiveRecord.+Assoc/                              => 'ActiveRecord/Associations',
        /\AActiveRecord.+Attribute/                          => 'ActiveRecord/Attributes',
        /\AActiveRecord.+ConnectionAdapters/                 => 'ActiveRecord/Connection',
        /\AActiveSupport.+(Subscriber|Notifications)/        => 'ActiveSupport/Instrumentation' }

      TYPE_BY_NAME_STARTS_WITH = {
        'ActionController::Parameters'  => 'ActionController/Parameters',
        'ActionDispatch::Integration'   => 'Testing',
        'ActionDispatch::Request'       => 'ActionDispatch/Request',
        'ActionDispatch::Response'      => 'ActionDispatch/Response',
        'ActionDispatch::Routing'       => 'ActionDispatch/Routing',
        'ActionView::Helpers'           => 'ActionView/Helpers',
        'ActiveModel::Errors'           => 'ActiveModel/Validation',
        'ActiveModel::Valid'            => 'ActiveModel/Validation',
        'ActiveRecord::Batches'         => 'ActiveRecord/Query',
        'ActiveRecord::Calculations'    => 'ActiveRecord/Query',
        'ActiveRecord::Connection'      => 'ActiveRecord/Connection',
        'ActiveRecord::FinderMethods'   => 'ActiveRecord/Query',
        'ActiveRecord::Migra'           => 'ActiveRecord/Migration',
        'ActiveRecord::Query'           => 'ActiveRecord/Query',
        'ActiveRecord::Relation'        => 'ActiveRecord/Relation',
        'ActiveRecord::Result'          => 'ActiveRecord/Connection',
        'ActiveRecord::Scoping'         => 'ActiveRecord/Query',
        'ActiveRecord::SpawnMethods'    => 'ActiveRecord/Query',
        'ActiveSupport::Cach'           => 'ActiveSupport/Caching',
        'ActiveSupport::Inflector'      => 'ActiveSupport/Inflector',
        'ActiveSupport::Time'           => 'ActiveSupport/TimeZones',
        'Rails::Application'            => 'Rails/Application',
        'Rails::Engine'                 => 'Rails/Engine',
        'Rails::Generators'             => 'Rails/Generators',
        'Rails::Railtie'                => 'Rails/Railtie' }

      def get_name
        if slug.start_with?('guides')
          name = at_css('#feature h2').content.strip
          name.remove! %r{\s\(.+\)\z}
          return name
        end

        super
      end

      def get_type
        return 'Guides' if slug.start_with?('guides')

        parent = at_css('.meta-parent').try(:content).to_s

        if [name, parent].any? { |str| str.end_with?('Error') || str.end_with?('Exception') }
          return 'Errors'
        end

        TYPE_BY_NAME_MATCHES.each_pair do |key, value|
          return value if name =~ key
        end

        TYPE_BY_NAME_STARTS_WITH.each_pair do |key, value|
          return value if name.start_with?(key)
        end

        super
      end

      def include_default_entry?
        return true if slug.start_with?('guides')

        super && !skip?
      end

      def additional_entries
        return [] if slug.start_with?('guides')

        skip? ? [] : super
      end

      def skip?
        @skip ||= !css('p').any? { |node| node.content.present? }
      end
    end
  end
end
