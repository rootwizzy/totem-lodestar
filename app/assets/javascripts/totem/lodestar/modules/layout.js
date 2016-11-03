TotemLodestar._modules['layout'] = {
  init: function(id, options) {
    TotemLodestar.load_module(id, this, options)
  },
  
  full_width: function(options) {
    pref = TotemLodestar.user_settings.get()['layout']['full_width']

    if (pref !== undefined) {
      if (pref) { expand(); } else { compress(); }
    } else {
      if (options['default']) { expand(); }
    }

    $('#layout-expand').on('click',function (e) {
      e.preventDefault();
      expand();
    });

    $('#layout-compress').on('click',function (e) {
      e.preventDefault();
      compress();
    });

    function expand() {
      // Checks if all layout_classes have the full class, if any do not then add full to all divs
      if (!($('.article').hasClass('full') & $('.top-nav_menu').hasClass('full'))) {
        layout_divs().addClass('full');
        Turbolinks.clearCache();
      }
      TotemLodestar.user_settings.set({layout: {full_width: true}});
    }

    function compress() {
      // Checks if all layout_classes have the full class, if any of them do then remove from all divs
      if (($('.article').hasClass('full') || $('.top-nav_menu').hasClass('full'))){
        layout_divs().removeClass('full');
        Turbolinks.clearCache();
      }
      TotemLodestar.user_settings.set({layout: {full_width: false}});
    }
    
    function layout_divs() {
      return $('.article, .top-nav_menu')
    }
  }
}