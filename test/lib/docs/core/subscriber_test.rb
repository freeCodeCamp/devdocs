# frozen_string_literal: true

require_relative '../../../test_helper'
require_relative '../../../../lib/docs'

class DocsSubscriberTest < Minitest::Spec
  let(:subscriber) { Docs::Subscriber.new }

  describe "#format_url" do
    it "removes http:// scheme" do
      assert_equal 'devdocs.test.co/path', subscriber.send(:format_url, 'http://devdocs.test.co/path')
    end

    it "removes https:// scheme" do
      assert_equal 'devdocs.test.co/path', subscriber.send(:format_url, 'https://devdocs.test.co/path')
    end

    it "returns non-http urls unchanged" do
      assert_equal 'devdocs.test.co/path', subscriber.send(:format_url, 'devdocs.test.co/path')
    end
  end

  describe "#format_path" do
    it "removes the current working directory prefix" do
      full_path = File.join(Dir.pwd, 'some/file.rb')
      assert_equal 'some/file.rb', subscriber.send(:format_path, full_path)
    end

    it "returns paths outside the cwd unchanged" do
      assert_equal '/other/path', subscriber.send(:format_path, '/other/path')
    end

    it "calls to_s on the argument" do
      path = Object.new
      def path.to_s; '/other/path'; end
      assert_equal '/other/path', subscriber.send(:format_path, path)
    end
  end

  describe "#justify" do
    describe "when terminal_width is nil" do
      before { subscriber.instance_variable_set(:@terminal_width, nil) }

      it "returns the string unchanged" do
        assert_equal 'hello', subscriber.send(:justify, 'hello')
      end
    end

    describe "when terminal_width is set" do
      before { subscriber.instance_variable_set(:@terminal_width, 20) }

      it "pads a short string to terminal width" do
        result = subscriber.send(:justify, 'hi')
        assert_equal 20, result.length
        assert result.start_with?('hi')
      end

      it "truncates a long string to terminal width" do
        result = subscriber.send(:justify, 'a' * 30)
        assert_equal 20, result.length
      end

      it "reserves space for a trailing tag and pads the rest" do
        result = subscriber.send(:justify, 'hi [tag]')
        assert_equal 20, result.length
        assert result.end_with?('[tag]')
      end

      it "truncates the non-tag part when the string is too long" do
        result = subscriber.send(:justify, ('a' * 30) + ' [tag]')
        assert_equal 20, result.length
        assert result.end_with?('[tag]')
      end
    end
  end

  describe "#terminal_width" do
    it "returns nil when stdout is not a tty" do
      old_stdout = $stdout
      $stdout = StringIO.new
      sub = Docs::Subscriber.new
      assert_nil sub.send(:terminal_width)
    ensure
      $stdout = old_stdout
    end

    it "reads COLUMNS env var when stdout is a tty" do
      sub = Docs::Subscriber.new
      # Override tty? on the instance to avoid needing a real tty
      def sub.tty?; true; end
      old_columns = ENV.delete('COLUMNS')
      ENV['COLUMNS'] = '666'
      assert_equal 666, sub.send(:terminal_width)
    ensure
      ENV['COLUMNS'] = old_columns
    end
  end
end
