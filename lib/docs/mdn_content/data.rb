require 'json'

module Docs
  module MdnContent
    # The data MDN pulls in when it builds a page: the browser compatibility
    # tables (@mdn/browser-compat-data), the titles of the specifications
    # (web-specs) and the Baseline status of the features (web-features).
    #
    # The packages are pruned down to what's actually needed when they're
    # downloaded (see .prepare). Their unpruned form weighs 25MB of JSON, which
    # the scraper would otherwise read in every one of its forked workers.
    class Data
      COMPAT = 'compat.json'
      SPECS = 'specs.json'
      BASELINE = 'baseline.json'
      CSS = 'css.json'

      def initialize(directory)
        @directory = directory
      end

      # The compatibility data of a feature, e.g. "javascript.builtins.Array.map".
      def compat(query)
        query.split('.').inject(compat_data) do |data, key|
          break nil unless data.is_a?(Hash)
          data[key]
        end
      end

      def browsers
        compat_data['browsers'] ||= {}
      end

      # The date a browser version was released, when it's known.
      def release_date(browser, version)
        browsers.dig(browser, 'releases', version, 'release_date')
      end

      # The specification a URL points into. The URLs in browser-compat-data
      # point at a section of the editor's draft more often than not, which is
      # why the nightly urls are matched as well.
      def spec(url)
        specs.find do |spec|
          url.start_with?(spec['url']) ||
            Array(spec['nightly_urls']).any? { |nightly| url.start_with?(nightly) }
        end
      end

      # The Baseline status of the feature a compatibility query documents.
      def baseline(query)
        baseline_data[query]
      end

      # What MDN knows about a CSS property, type, function or at-rule beyond
      # its own prose: its formal syntax and the table of its characteristics.
      def css(kind, name)
        css_data.dig(kind, name)
      end

      # The definition of a CSS value type, e.g. "single-animation".
      def css_syntax(name)
        css_data.dig('syntaxes', name)
      end

      # The English of the enumerated values of mdn-data, e.g. "allElements".
      def css_string(key)
        css_data.dig('l10n', key)
      end

      private

      def compat_data
        @compat_data ||= read(COMPAT)
      end

      def specs
        @specs ||= read(SPECS)
      end

      def baseline_data
        @baseline_data ||= read(BASELINE)
      end

      def css_data
        @css_data ||= File.exist?(File.join(@directory, CSS)) ? read(CSS) : {}
      end

      def read(name)
        JSON.parse File.read(File.join(@directory, name))
      end

      class << self
        # Turns the three packages unpacked into directory into the files the
        # scraper reads, and removes them. Only the sections of the
        # compatibility data the documentation queries are kept.
        def prepare(directory, namespaces)
          prepare_compat directory, namespaces
          prepare_specs directory
          prepare_baseline directory, namespaces
          prepare_css directory if Dir.exist?(File.join(directory, 'mdn-data'))
          FileUtils.rm_rf File.join(directory, 'mdn-data')
        end

        private

        def prepare_compat(directory, namespaces)
          data = read_package(directory, 'browser-compat-data', 'data.json')
          write directory, COMPAT, data.slice('browsers', *namespaces)
        end

        def prepare_specs(directory)
          specs = read_package(directory, 'web-specs', 'index.json')

          # Only the series' nightly url of the current specification is worth
          # keeping: an older version would shadow the one MDN links to.
          specs = specs.map do |spec|
            nightly_urls = []
            nightly_urls.push(spec.dig('nightly', 'url'), *spec.dig('nightly', 'alternateUrls'))
            nightly_urls << spec.dig('series', 'nightlyUrl') if spec['shortname'] == spec.dig('series', 'currentSpecification')
            { 'url' => spec['url'], 'title' => spec['title'], 'nightly_urls' => nightly_urls.compact.uniq }
          end

          write directory, SPECS, specs
        end

        def prepare_baseline(directory, namespaces)
          data = read_package(directory, 'web-features', 'data.json')
          sections = namespaces.map { |namespace| "#{namespace}." }
          baseline = {}

          data['features'].each_value do |feature|
            status = feature['status']
            next unless status

            Array(feature['compat_features']).each do |query|
              next unless sections.any? { |section| query.start_with?(section) }
              baseline[query] = status.slice('baseline', 'baseline_low_date', 'baseline_high_date')
            end
          end

          write directory, BASELINE, baseline
        end

        # What the CSS documentation reads out of mdn-data: the formal syntax
        # of every property, type, function and at-rule, the characteristics
        # MDN tabulates below it, and the English of the values it names.
        CSS_FIELDS = %w(syntax initial appliesto inherited percentages computed animationType)

        def prepare_css(directory)
          css = {}

          %w(properties types functions at-rules).each do |file|
            data = read_package(directory, 'mdn-data', "css/#{file}.json", keep: true)
            css[file] = data.transform_values { |value| slice_css value }
          end

          syntaxes = read_package(directory, 'mdn-data', 'css/syntaxes.json', keep: true)
          css['syntaxes'] = syntaxes.transform_values { |value| value['syntax'] }

          strings = read_package(directory, 'mdn-data', 'l10n/css.json', keep: true)
          css['l10n'] = strings.transform_values { |translations| translations['en-US'] }.compact

          write directory, CSS, css
        end

        def slice_css(value)
          sliced = value.slice(*CSS_FIELDS)
          descriptors = value['descriptors']
          sliced['descriptors'] = descriptors.transform_values { |descriptor| descriptor.slice(*CSS_FIELDS) } if descriptors
          sliced
        end

        def read_package(directory, name, file, keep: false)
          JSON.parse File.read(File.join(directory, name, file))
        ensure
          FileUtils.rm_rf File.join(directory, name) unless keep
        end

        def write(directory, name, data)
          File.write File.join(directory, name), JSON.generate(data)
        end
      end
    end
  end
end
