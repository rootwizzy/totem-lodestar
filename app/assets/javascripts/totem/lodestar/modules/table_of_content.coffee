window.TotemLodestar._modules['table_of_contents'] =
  init: (id, options) ->
    TotemLodestar.load_module id, this, options
    return

  smooth_scroll: (options) ->
    speed = options['speed']
    $('a[href^="#"]').on 'click', (e) ->
      e.preventDefault()
      target = @hash
      $target = $(target)
      $('html, body').stop().animate { 'scrollTop': $target.offset().top }, speed, 'swing', ->
        window.location.hash = target
        return
      return
    return

  highlight: (options) ->

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

    ticking    = false
    regions    = []
    cur_region = null

    build_document_positions()
    check_header_pos window.scrollY, cur_region
    # Initialize to set the first region active
    window.addEventListener 'scroll', (e) ->
      if !ticking
        window.requestAnimationFrame ->
          check_header_pos window.scrollY, cur_region
          ticking = false
          return
      ticking = true
      return
    return




