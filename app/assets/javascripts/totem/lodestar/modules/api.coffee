# # API module
# The api module is only used for grabbing the url location to insert into the Groc Table of Content links. This is where totem-lodestar integrates with the Groc behavior.js, see [here](https://github.com/rootwizzy/groc/blob/master/lib/styles/default/behavior.coffee) in the `buildTOCNode` function.
window.TotemLodestar._modules['api'] =

  init: (id, options) -> TotemLodestar.load_module id, this, options

  # This is needed just to satisfy the loader's module/plugin workflow.
  repositories: (options) ->

  # Grabs the current window URL and grabs the path past /api/
  get_cur_repo: ->
    /^\/api\/([1-9a-z-]*)/g.exec(window.location.pathname)[1]

