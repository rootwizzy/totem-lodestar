# Table Of Contents Module
# The table of contents appears on the right hand side of the page and tracks the current position in the markdown document to provide highlighting and navigation.
window.TotemLodestar._modules['table_of_contents'] =
  init: (id, options) ->
    TotemLodestar.load_module id, this, options
    return

  # ## Smooth Scroll Plugin
  # Smooth scroll applies an animation to the page scroll when a table of contents navigation link is clicked. The speed of the animation is set via the settings.yml
  smooth_scroll: (options) ->
    speed = options['speed']
    $('.toc_list').children().on 'click', (e) ->
      e.preventDefault()
      target = @hash
      $target = $(target)
      $('html, body').stop().animate { 'scrollTop': $target.offset().top }, speed, 'swing', ->
        window.location.hash = target
        return
      return
    return

  # ## Highlight Plugin
  # The highlight plugin scrapes each header region in the markdown document and makes its best guess as to where in the document you are looking at, then apply a highlight class to the corresponding header in the table of contents.
  highlight: (options) ->
    ticking    = false
    regions    = []
    cur_region = null

    # Initalize the regions based on the document position of the headers
    build_document_positions()

    # Initialize to set the first region active
    check_header_pos window.scrollY, cur_region

    # Attach event listener to scroll, this can be costly for performance, so using ticking, and requestAnimationFrame are used to try and reduce the amount of processing done per cycle.
    #
    window.addEventListener 'scroll', (e) ->
      if !ticking
        window.requestAnimationFrame ->
          # check_header_pos will take the current postion and region and diffs that to see if the cur_region needs to be activated/deactivated
          check_header_pos window.scrollY, cur_region
          ticking = false
          return
      ticking = true
      return
    return

    build_document_positions = ->
      $('h1, h2, h3, h4, h5, h6').each ->
        regions.push
          top: 0
          bottom: $(this)[0].offsetTop
          $: $(this)
        return
      prev = null
      regions.forEach (header) ->
        if prev
          header.top = prev.bottom - 1
        prev = header
        return
      return

    check_header_pos = (pos, cur_region) =>
      if cur_region == null or pos < cur_region.top or pos > cur_region.bottom
        set_cur_region pos, cur_region
      return

    set_cur_region = (pos, cur_region) =>
      regions.forEach (header) ->
        if pos >= header.top and pos <= header.bottom
          cur_region = header
        return
      activate_toc_header cur_region
      return

    activate_toc_header = (cur_region) ->
      header_href = '#' + cur_region.$[0].id
      $('.toc_list').children('a[href="' + header_href + '"]').addClass 'active'
      $('.toc_list').children(':not(a[href="' + header_href + '"])').removeClass 'active'
      return






