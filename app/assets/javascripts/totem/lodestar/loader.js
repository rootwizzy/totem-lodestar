var TotemLodestar = {
  _modules: {},

  load: function() {
    this.version = $('.settings').data('version')
    this.user_settings._init()

    settings     = $('.settings').data('settings')
    for (module in this._modules) {
      this._modules[module].init(module, settings['modules'][module]);
    }
  },

  load_module: function(id, module, settings) {
    module._settings = settings
    module._id       = id
    this.load_module_plugins(module)
  },

  load_module_plugins: function(module) {
    for (plugin in module._settings) {
      module[plugin](module._settings[plugin])
    }
  },

  user_settings: {
    _init: function() {
      // Cookies.defaults = {expires: 30}
      if (Cookies.get('TotemLodestar')) {return}
      Cookies.set('TotemLodestar', this._defaults)
    },

    _defaults: {
      layout: {
        full_width: true
      },
    },

    set: function(value) {
      Cookies.set('TotemLodestar', value)
    },

    get: function(cname) {
      return Cookies.getJSON('TotemLodestar')
    },

    remove: function(cname) {}
  },
}



