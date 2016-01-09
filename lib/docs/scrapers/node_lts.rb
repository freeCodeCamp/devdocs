module Docs
  class NodeLts < Node
    self.name = 'Node.js (LTS)'
    self.slug = 'node_lts'
    self.type = 'node'
    self.version = '4.2.4'
    self.base_url = "https://nodejs.org/dist/v#{version}/docs/api/"
  end
end
