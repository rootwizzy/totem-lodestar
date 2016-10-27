var TotemLodestar = {
  _modules: {},

  load: function() {
    this.version = $('.settings').data('version')
    settings     = $('.settings').data('settings')

    for (module in this._modules) {
      this._modules[module].init(settings['modules'][module]);
    }
  },

  load_module: function(module, options) {
    module._settings = options
    this.load_module_plugins(module)
  },

  load_module_plugins: function(module) {
    for (plugin in module._settings) {
      module[plugin](module._settings[plugin])
    }
  },
}



