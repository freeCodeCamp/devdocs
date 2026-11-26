require_relative '../../../test_helper'
require_relative '../../../../lib/docs'

class ReactScraperTest < Minitest::Test
  INDEX_JS = "import { createRoot } from 'react-dom/client';\nimport App from './App';\n\ncreateRoot(document.getElementById('root')).render(<App />);\n"
  STRICT_INDEX_JS = "import { StrictMode } from 'react';\nimport { createRoot } from 'react-dom/client';\nimport App from './App';\n\ncreateRoot(document.getElementById('root')).render(<StrictMode><App /></StrictMode>);\n"
  APP_JS = "import StoryTray from './StoryTray.js';\n\nexport default function App() {\n  return <StoryTray stories={[]} />;\n}\n"
  STORY_TRAY_JS = "export default function StoryTray({ stories }) {\n  return <ul>{stories.length}</ul>;\n}\n"
  STYLES_CSS = "ul { margin: 0; }\n"

  def test_shows_every_file_of_a_sandpack_example
    result = scrape(
      playground([['/src/index.js', 'index.js'], ['/src/App.js', 'App.js'], ['/src/StoryTray.js', 'StoryTray.js']], active: '/src/StoryTray.js', code: STORY_TRAY_JS),
      [sandpack([['src/index.js', 'js', INDEX_JS], ['src/App.js', 'js', APP_JS], ['src/StoryTray.js active', 'js', STORY_TRAY_JS], [nil, 'css', STYLES_CSS]])]
    )

    assert_equal %w(index.js App.js StoryTray.js), files(result).map(&:first)
    assert_equal [INDEX_JS, APP_JS, STORY_TRAY_JS], files(result).map(&:last).map(&:content)
    assert_equal %w(jsx jsx jsx), files(result).map { |_, pre| pre['data-language'] }
    refute_includes result[:output], 'margin: 0'
  end

  def test_pairs_examples_with_the_same_active_file_in_page_order
    tabs = [['/src/index.js', 'index.js'], ['/src/App.js', 'App.js']]
    result = scrape(
      playground(tabs, active: '/src/App.js', code: APP_JS) + playground(tabs, active: '/src/App.js', code: APP_JS),
      [
        sandpack([['src/index.js', 'js', INDEX_JS], ['src/App.js active', 'js', APP_JS]]),
        sandpack([['src/index.js', 'js', STRICT_INDEX_JS], ['src/App.js active', 'js', APP_JS]])
      ]
    )

    index_files = files(result).select { |name, _| name == 'index.js' }.map(&:last).map(&:content)
    assert_equal [INDEX_JS, STRICT_INDEX_JS], index_files
  end

  def test_skips_examples_that_are_not_rendered_on_the_page
    # Challenges and recipes only render their first example; the others are only in the page data.
    hidden_app = "export default function App() {\n  return <p>Challenge 2</p>;\n}\n"
    result = scrape(
      playground([['/src/App.js', 'App.js'], ['/src/StoryTray.js', 'StoryTray.js']], active: '/src/App.js', code: APP_JS),
      [
        sandpack([['src/App.js', 'js', hidden_app], ['src/StoryTray.js', 'js', 'export default function StoryTray() {}']]),
        sandpack([['src/App.js', 'js', APP_JS], ['src/StoryTray.js', 'js', STORY_TRAY_JS]])
      ]
    )

    assert_equal [APP_JS, STORY_TRAY_JS], files(result).map(&:last).map(&:content)
  end

  def test_does_not_borrow_files_after_an_example_fails_to_match
    tabs = [['/src/index.js', 'index.js'], ['/src/App.js', 'App.js']]
    result = scrape(
      playground(tabs, active: '/src/App.js', code: "export default function App() {\n  return <p>cut off") +
        playground(tabs, active: '/src/App.js', code: APP_JS),
      [
        sandpack([['src/index.js', 'js', INDEX_JS], ['src/App.js active', 'js', APP_JS]]),
        sandpack([['src/index.js', 'js', STRICT_INDEX_JS], ['src/App.js active', 'js', APP_JS]])
      ]
    )

    assert_empty files(result)
    refute_includes result[:output], 'react-dom/client'
  end

  def test_keeps_ambiguous_examples_after_skipping_examples_that_are_not_rendered
    hidden_app = "export default function App() {\n  return <p>Challenge 2</p>;\n}\n"
    tabs = [['/src/index.js', 'index.js'], ['/src/App.js', 'App.js']]
    result = scrape(
      playground([['/src/App.js', 'App.js']], active: '/src/App.js', code: APP_JS) + playground(tabs, active: '/src/App.js', code: APP_JS),
      [
        sandpack([['src/App.js', 'js', hidden_app]]),
        sandpack([['src/App.js', 'js', APP_JS]]),
        sandpack([['src/index.js', 'js', INDEX_JS], ['src/App.js active', 'js', APP_JS]]),
        sandpack([['src/index.js', 'js', STRICT_INDEX_JS], ['src/App.js active', 'js', APP_JS]])
      ]
    )

    assert_equal %w(App.js), files(result).map(&:first)
    refute_includes result[:output], 'react-dom/client'
  end

  def test_does_not_take_files_from_hidden_recipes
    recipe_app = "export default function App() {\n  return <p>Recipe 1</p>;\n}\n"
    tabs = [['/src/index.js', 'index.js'], ['/src/App.js', 'App.js']]
    result = scrape(
      playground(tabs, active: '/src/App.js', code: recipe_app) + playground(tabs, active: '/src/App.js', code: APP_JS),
      [
        ['$r', 'Recipes', nil, { children: [
          sandpack([['src/index.js', 'js', INDEX_JS], ['src/App.js active', 'js', recipe_app]]),
          sandpack([['src/index.js', 'js', INDEX_JS], ['src/App.js active', 'js', APP_JS]])
        ] }],
        sandpack([['src/index.js', 'js', STRICT_INDEX_JS], ['src/App.js active', 'js', APP_JS]])
      ]
    )

    assert_equal [INDEX_JS, recipe_app], files(result).map(&:last).map(&:content)
  end

  def test_matches_a_package_json_rendered_with_empty_dev_dependencies
    package = %({\n  "dependencies": {\n    "immer": "1.7.3"\n  }\n}\n)
    rendered = %({\n  "dependencies": {\n    "immer": "1.7.3"\n  },\n  "devDependencies": {}\n}\n)
    result = scrape(
      playground([['/package.json', 'package.json'], ['/src/App.js', 'App.js']], active: '/package.json', code: rendered),
      [sandpack([['package.json', 'json', package], ['src/App.js', 'js', APP_JS]])]
    )

    assert_equal [['package.json', package, 'json'], ['App.js', APP_JS, 'jsx']], files(result).map { |name, pre| [name, pre.content, pre['data-language']] }
  end

  def test_ignores_options_in_braces_when_reading_file_names
    result = scrape(
      playground([['/src/App.js', 'App.js'], ['/src/StoryTray.js', 'StoryTray.js']], active: '/src/App.js', code: APP_JS),
      [sandpack([['{2-4} src/App.js', 'js', APP_JS], ["src/StoryTray.js {expectedErrors: {'react-compiler': [4]}}", 'js', STORY_TRAY_JS]])]
    )

    assert_equal [APP_JS, STORY_TRAY_JS], files(result).map(&:last).map(&:content)
  end

  def test_shows_every_file_in_the_react_18_documentation
    result = scrape(
      playground([['/src/App.js', 'App.js'], ['/src/StoryTray.js', 'StoryTray.js']], active: '/src/App.js', code: APP_JS),
      [sandpack([['src/App.js', 'js', APP_JS], ['src/StoryTray.js', 'js', STORY_TRAY_JS]])],
      version: '18'
    )

    assert_equal %w(App.js StoryTray.js), files(result).map(&:first)
  end

  def test_uses_the_language_of_each_file
    html = "<!DOCTYPE html>\n<html><body><div id=\"root\"></div></body></html>\n"
    result = scrape(
      playground([['/src/index.js', 'index.js'], ['/public/index.html', 'index.html']], active: '/src/index.js', code: INDEX_JS),
      [sandpack([['src/index.js active', 'js', INDEX_JS], ['public/index.html', 'html', html]])]
    )

    assert_equal %w(jsx html), files(result).map { |_, pre| pre['data-language'] }
    assert_equal html, files(result).last.last.content
  end

  def test_keeps_the_rendered_file_when_the_page_data_does_not_match
    result = scrape(
      playground([['/src/index.js', 'index.js'], ['/src/App.js', 'App.js']], active: '/src/App.js', code: APP_JS),
      [sandpack([['src/index.js', 'js', INDEX_JS], ['src/App.js active', 'js', "export default function Other() {}\n"]])]
    )

    assert_empty files(result)
    assert_equal [APP_JS.strip], output(result).css('pre').map { |pre| pre.content.strip }
  end

  def test_keeps_the_rendered_file_without_page_data
    result = scrape(playground([['/src/index.js', 'index.js'], ['/src/App.js', 'App.js']], active: '/src/App.js', code: APP_JS), nil)

    assert_empty files(result)
    assert_equal [APP_JS.strip], output(result).css('pre').map { |pre| pre.content.strip }
  end

  private

  def scrape(body, sandpacks, version: '')
    data = sandpacks && { props: { pageProps: { content: [['$r', 'MaxWidth', nil, { children: sandpacks }]].to_json } } }
    html = <<~HTML
      <html><body>
        <article><div>Reference</div><h1>StrictMode</h1>#{body}</article>
        #{%(<script id="__NEXT_DATA__" type="application/json">#{data.to_json}</script>) if data}
      </body></html>
    HTML
    scraper = Docs::React.versions.find { |doc| doc.version == version }.new
    context = scraper.options.merge(url: Docs::URL.parse("#{scraper.base_url}/reference/react/StrictMode"), download_images: false)
    scraper.pipeline.call(Docs::Parser.new(html).html, context)
  end

  # Markup of a react.dev Sandpack example: a tab per visible file, and only the active file's code.
  def playground(tabs, active:, code:)
    buttons = tabs.map do |path, label|
      %(<button aria-selected="#{path == active}" class="sp-tab-button" data-active="#{path == active}" role="tab" title="#{path}" type="button">#{label}</button>)
    end
    tokens = CGI.escapeHTML(code).gsub(/\S+/) { |token| %(<span class="sp-syntax-plain">#{token}</span>) }
    <<~HTML
      <div class="sandpack sandpack--playground w-full my-8" dir="ltr"><div class="sp-wrapper"><div class="shadow-lg">
        <div class="sp-tabs" translate="no"><div aria-label="Select active file" role="tablist">#{buttons.join}</div></div>
        <div class="sp-stack"><div class="sp-code-editor"><pre class=" sp-pre-placeholder">#{tokens}</pre></div></div>
        <div class="order-last"><iframe title="Sandbox Preview"></iframe></div>
      </div></div></div>
    HTML
  end

  # A <Sandpack> element as serialized in react.dev's __NEXT_DATA__.
  def sandpack(files)
    children = files.map do |meta, language, code|
      props = { className: "language-#{language}", children: code }
      props[:meta] = meta if meta
      ['$r', 'pre', nil, { children: ['$r', 'code', nil, props] }]
    end
    ['$r', 'Sandpack', nil, { children: children }]
  end

  def files(result)
    output(result).css('div._pre-heading').map { |heading| [heading.content, heading.next_element] }
  end

  def output(result)
    Nokogiri::HTML.fragment(result[:output])
  end
end
