# # Side Bar Module
# The side bar module handles the collapsing of the nested navigation links.
window.TotemLodestar._modules['side_bar'] =
  init: (id, options) -> TotemLodestar.load_module id, this, options

  # ## Collapse Plugin
  # If enabled this allows the navigation menu headers to be collapsed and changes their corresponding icon.
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

