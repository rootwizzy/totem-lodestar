# # Layout Module
# The layout module handles setting the layout of the page from a full_width layout or a centered layout. This also interacts the the user_settings cookies to try and save this preference.
window.TotemLodestar._modules['layout'] =

  init: (id, options) -> TotemLodestar.load_module id, this, options

  # ## Full Width Plugin
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

    # Pref grabs the current user_settings options and checks what they were set to, then calls the correct method to expand or compress the layout to the desired layout.
    pref = TotemLodestar.user_settings.get()['layout']['full_width']
    if pref != undefined
      if pref
        expand()
      else
        compress()
    else
      if options['default']
        expand()

    # Sets a click listening on the layout style button above the side_nav to call the method and set the user settings and icons accordingly.
    $('#layout-style').on 'click', (e) ->
      e.preventDefault()
      if layout_divs().hasClass 'full'
        compress()
        set_layout_button_to 'expand'
      else
        expand()
        set_layout_button_to 'compress'


