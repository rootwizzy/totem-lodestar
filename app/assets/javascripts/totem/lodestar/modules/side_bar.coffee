window.TotemLodestar._modules['side_bar'] =
  init: (id, options) -> TotemLodestar.load_module id, this, options

  collapse: (options) ->
    expanded_icon  = options['expanded_icon']
    collapsed_icon = options['collapsed_icon']

    $('.side-nav_section-header').on 'click', (e) ->
      e.preventDefault()
      $(this).parent().toggleClass 'collapsed'
      icon = $(this).children()[0]
      
      if icon.className == collapsed_icon
        icon.className = expanded_icon
      else
        icon.className = collapsed_icon

