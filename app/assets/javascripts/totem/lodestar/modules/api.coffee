window.TotemLodestar._modules['api'] =

  init: (id, options) -> TotemLodestar.load_module id, this, options

  repositories: (options) ->

  get_cur_repo: ->
    /^\/api\/([1-9a-z-]*)/g.exec(window.location.pathname)[1]

