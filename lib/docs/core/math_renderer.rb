# frozen_string_literal: true

require 'execjs'
require 'katex'

module Docs
  module MathRenderer
    class Error < StandardError; end

    class RuntimeUnavailable < SetupError
      def initialize
        super "Rendering math requires a JavaScript runtime (e.g. Node.js) to be installed. " \
              "See https://github.com/rails/execjs#readme for the list of supported runtimes."
      end
    end

    # Options passed to katex.renderToString (https://katex.org/docs/options).
    OPTIONS = {
      output: 'mathml',
      throwOnError: true,
      strict: false, # don't warn about non-strict LaTeX like Unicode text
      trust: false
    }.freeze

    BATCH_JS = <<~JS
      function renderMathBatch(items, options) {
        return items.map(function(item) {
          try {
            return { html: katex.renderToString(item.tex, Object.assign({ displayMode: item.display }, options)) };
          } catch (error) {
            return { error: String(error.message || error) };
          }
        });
      }
    JS

    MATH_RGX = /<math\b.*<\/math>/m

    # MathJax tolerates bare underscores in text mode (e.g. \text{log_loss}),
    # which KaTeX rejects, so escape them before rendering.
    TEXT_COMMAND_RGX = /\\text(?:rm|bf|it|sf|tt|normal)?\{[^{}]*\}/
    BARE_UNDERSCORE_RGX = /(?<!\\)_/

    class << self
      # Renders a single expression to a <math> element.
      def to_mathml(tex, display: false)
        result = render_all([[tex, display]]).first
        raise result[:error] if result[:error]
        result[:mathml]
      end

      # Renders many expressions in a single JavaScript call.
      def render_all(items)
        return [] if items.empty?

        payload = items.map { |tex, display| { tex: normalize(tex.to_s), display: display ? true : false } }
        context.call('renderMathBatch', payload, OPTIONS).map do |result|
          if result['error']
            { error: Error.new(result['error']) }
          else
            { mathml: result['html'][MATH_RGX] }
          end
        end
      rescue ExecJS::RuntimeUnavailable
        raise RuntimeUnavailable
      end

      def render(tex, display: false)
        to_mathml(tex, display: display)
      rescue Error
        fallback(tex, display: display)
      end

      def normalize(tex)
        tex.gsub(TEXT_COMMAND_RGX) { |text| text.gsub(BARE_UNDERSCORE_RGX, '\\_') }
      end

      def fallback(tex, display: false)
        tag = display ? 'pre' : 'code'
        %(<#{tag} class="_math-fallback">#{CGI.escapeHTML(tex)}</#{tag}>)
      end

      def context
        @context ||= ExecJS.compile(File.read(Katex.katex_js_path) + BATCH_JS)
      rescue ExecJS::RuntimeUnavailable
        raise RuntimeUnavailable
      end

      def reset!
        @context = nil
      end
    end
  end
end
