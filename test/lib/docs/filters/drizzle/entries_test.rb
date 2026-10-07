require_relative '../../../../test_helper'
require_relative '../../../../../lib/docs'

class DrizzleEntriesFilterTest < Minitest::Spec
  include FilterTestHelper
  self.filter_class = Docs::Drizzle::EntriesFilter
  self.filter_type = 'html'

  def page(slug, label:, section: 'Access your data', content: '')
    context[:base_url] = 'https://orm.drizzle.team/docs/'
    context[:url] = "https://orm.drizzle.team/docs/#{slug}"
    context[:root_path] = 'overview'
    result[:path] = slug

    @body = <<-HTML
      <div class="nav-items">
        <div class="nav-separator">#{section}</div>
        <a class="nav-item nav-item-1" href="/docs/other">Other</a>
        <a class="nav-item--active nav-item-1" href="/docs/#{slug}">#{label}</a>
      </div>
      <main><div class="documentation-content"><h1>Title</h1>#{content}</div></main>
    HTML
  end

  def entries
    filter_result[:entries].map { |entry| [entry.name, entry.path, entry.type] }
  end

  it "names the pages after their sidebar label, under their sidebar section" do
    page 'select', label: 'Select'
    assert_equal [['Select', 'select', 'Access your data']], entries
  end

  it "renames the labels too vague out of the sidebar" do
    page 'kit-overview', label: 'Overview', section: 'Migrations'
    assert_equal [['Drizzle Kit', 'kit-overview', 'Migrations']], entries
  end

  it "prefixes the drizzle-kit commands with drizzle-kit" do
    page 'drizzle-kit-push', label: 'push', section: 'Migrations'
    assert_equal 'drizzle-kit push', entries.first.first
  end

  it "marks the pages of APIs superseded in v1 as legacy" do
    page 'relations', label: '[OLD] Drizzle Relations', section: 'Manage schema'
    assert_equal 'Drizzle Relations (legacy)', entries.first.first
  end

  it "marks renamed pages of APIs superseded in v1 as legacy" do
    page 'rqb', label: '[OLD] Query V1'
    assert_equal 'Relational queries (legacy)', entries.first.first
  end

  it "drops the RC of the upgrade guides' section" do
    page 'upgrade-v1', label: 'How to upgrade?', section: 'Upgrade to v1.0 RC'
    assert_equal [['Upgrading to v1', 'upgrade-v1', 'Upgrade to v1.0']], entries
  end

  it "indexes the sections, leaving out separators and boilerplate ones" do
    page 'select', label: 'Select', content: <<-HTML
      <h3 id="basic-select">Basic select</h3>
      <h2 id="---">---</h2>
      <h3 id="filters">Filters</h3>
      <h4 id="details">Details</h4>
      <h3 id="install-the-dependencies">Install the dependencies</h3>
    HTML

    assert_equal [
      ['Select', 'select', 'Access your data'],
      ['Select: Basic select', 'select#basic-select', 'Access your data'],
      ['Select: Filters', 'select#filters', 'Access your data']
    ], entries
  end

  it "indexes the sections of API pages under their own name and type" do
    page 'operators', label: 'Filters', content: '<h3 id="eq">eq</h3><h2 id="---">---</h2><h3 id="ne">ne</h3>'
    assert_equal [
      ['Filters', 'operators', 'Access your data'],
      ['eq', 'operators#eq', 'Filters'],
      ['ne', 'operators#ne', 'Filters']
    ], entries
  end

  it "names the seed generators as they are called" do
    page 'seed-functions', label: 'Generators', section: 'Seeding', content: '<h3 id="int"><code>int</code></h3>'
    assert_equal [
      ['Seed generators', 'seed-functions', 'Seeding'],
      ['funcs.int()', 'seed-functions#int', 'Seed generators']
    ], entries
  end

  it "indexes the sql operator's methods under their own name" do
    page 'sql', label: 'Magic sql operator', content: <<-HTML
      <h2 id="sql-template">sql“ template</h2>
      <h2 id="sqlraw">sql.raw()</h2>
      <h2 id="sql-select">sql select</h2>
    HTML

    assert_equal [
      ['Magic sql operator', 'sql', 'Access your data'],
      ['sql`` template', 'sql#sql-template', 'Access your data'],
      ['sql.raw()', 'sql#sqlraw', 'Access your data'],
      ['Magic sql operator: sql select', 'sql#sql-select', 'Access your data']
    ], entries
  end

  it "doesn't index the sections of the drivers' pages" do
    page 'connect-neon', label: 'Neon', section: 'Connect', content: '<h2 id="node-postgres">node-postgres</h2>'
    assert_equal [['Neon', 'connect-neon', 'Connect']], entries
  end
end
