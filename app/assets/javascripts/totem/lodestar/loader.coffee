# # Totem Lodestar Loader
# The loader is responsible for initializing modules with the settings passed in from the `settings.yml` from the host application. A module is defined inside of the `./modules` folder and a module can have any number of plug ins associated with it. The structure of modules to plug ins at the moment is rigid.

# Example Settings Format
# ```
# // host_app/config/settings.yml
#
# ...
#
# modules:
#  foo_module:
#    bar_plugin:
#      baz_var: true
# ```

# Attach the TotemLodestar object to the global namespace, this will contain all our modules and settings.
window.TotemLodestar =
  _modules: {}

  # load()
  # Load is the main entry point and is called after the page has been flagged ready by turbo links.
  load: ->
    # Set the version of this object to reflect the settings passed in version
    this.version = $('.settings').data('version')

    # user_settings is the cookie for storing if the site layout is in full_width or centered. 
    this.user_settings._init()

    # Grab all module settings from the settings element passed in from the host application.
    settings     = $('.settings').data('settings')

    # Iterate over each module in the hash of modules and call their initialize function defined in each module passing in the corresponding settings hash. The roundabout loading process here is to dynamically be able to load modules as new ones are added or changed between host applications.
    #
    # Modules are appended into the object via their declaration in their module file. The Init function on each module just proxies back to the loader with the `this` context, the name of the modules and settings. Once set it then does a similar process for the module plug ins and then has completed the initialization of settings for each module.
    for module of this._modules
      this._modules[module].init(module, settings['modules'][module]);

  load_module: (id, module, settings) ->
    module._settings = settings
    module._id       = id
    this.load_module_plugins(module)

  load_module_plugins: (module) ->
    for plugin of module._settings
      module[plugin](module._settings[plugin])
    

  user_settings: 
    _init: ->
      # Cookies.defaults = {expires: 30}
      if Cookies.get('TotemLodestar') then return
      Cookies.set('TotemLodestar', this._defaults)

    _defaults: 
      layout: 
        full_width: true

    set: (value) -> Cookies.set('TotemLodestar', value)
    get: (cname) -> return Cookies.getJSON('TotemLodestar')
    remove: (cname) -> console.log 'Needs implementation'



