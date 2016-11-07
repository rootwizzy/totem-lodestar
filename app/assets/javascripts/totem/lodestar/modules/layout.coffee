window.TotemLodestar._modules['layout'] =

  init: (id, options) -> TotemLodestar.load_module id, this, options

  full_width: (options) ->
    expand = ->
      # Checks if all layout_classes have the full class, if any don't then add full to all divs
      TotemLodestar.user_settings.set layout: full_width: true
      layout_divs().addClass 'full'
      Turbolinks.clearCache()

    compress = ->
      # Checks if all layout_classes have the full class, if any do then remove from all divs
      TotemLodestar.user_settings.set layout: full_width: false
      layout_divs().removeClass 'full'
      Turbolinks.clearCache()

    layout_divs = -> $ '.article, .top-nav_menu'

    set_layout_button_to = (direction) ->
      switch direction
        when 'compress'
          $('#layout-style').children('i').removeClass('fa-expand').addClass 'fa-compress'
        when 'expand'
          $('#layout-style').children('i').removeClass('fa-compress').addClass 'fa-expand'
      return

    pref = TotemLodestar.user_settings.get()['layout']['full_width']
    if pref != undefined
      if pref
        expand()
      else
        compress()
    else
      if options['default']
        expand()

    $('#layout-style').on 'click', (e) ->
      e.preventDefault()
      if layout_divs().hasClass 'full'
        compress()
        set_layout_button_to 'expand'
      else
        expand()
        set_layout_button_to 'compress'


