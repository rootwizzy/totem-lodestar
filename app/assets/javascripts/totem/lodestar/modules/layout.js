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

    $('#layout-style').on('click',function (e) {
      e.preventDefault();

      if (layout_divs().hasClass('full')) {
        compress();
        set_layout_button_to('expand');
      } else {
        expand();
        set_layout_button_to('compress');
      }

    });

    function expand() {
      // Checks if all layout_classes have the full class, if any don't then add full to all divs
      TotemLodestar.user_settings.set({layout: {full_width: true}});
      layout_divs().addClass('full')
      Turbolinks.clearCache();
    }

    function compress() {
      // Checks if all layout_classes have the full class, if any do then remove from all divs
      TotemLodestar.user_settings.set({layout: {full_width: false}});
      layout_divs().removeClass('full');
      Turbolinks.clearCache();
    }
    
    function layout_divs() {
      return $('.article, .top-nav_menu')
    }

    function set_layout_button_to(direction) {
      switch(direction) {
        case 'compress':
          $('#layout-style').children('i').removeClass('fa-expand').addClass('fa-compress')
          break;
        case 'expand':
          $('#layout-style').children('i').removeClass('fa-compress').addClass('fa-expand')
          break;
      }
    }
  }
}