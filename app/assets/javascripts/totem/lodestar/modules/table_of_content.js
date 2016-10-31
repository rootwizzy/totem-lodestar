TotemLodestar._modules['table_of_contents'] = {
  init: function(options) {
    TotemLodestar.load_module(this, options)
  },

  smooth_scroll: function(options) {
    speed = options['speed']

    $('a[href^="#"]').on('click',function (e) {
      e.preventDefault();

      var target = this.hash;
      var $target = $(target);

      $('html, body').stop().animate({
          'scrollTop': $target.offset().top
      }, speed, 'swing', function () {
          window.location.hash = target;
      });
    });
  },

  highlight: function(options) {
    ticking       = false;
    region_lookup = []
    cur_region    = null

    set_document_positions();

    window.addEventListener('scroll', function(e){
      last_known_scroll_position = window.scrollY;
      if (!ticking) {
        window.requestAnimationFrame(function() {
          check_header_pos(last_known_scroll_position)
          ticking = false;
        });
      }
      ticking = true;
    }) 

    function set_document_positions() {
      headers = $("h1, h2, h3, h4, h5, h6")

      headers.each(function(i){
        region_lookup.push({top: 0, bottom: $(this)[0].offsetTop, $: $(this)});
      }, this)

      prev = null
      region_lookup.forEach(function(header){
        if(prev) { header.top = prev.bottom - 1 }
        prev = header
      })
    }

    function check_header_pos(pos) {
      if(cur_region == null || pos < cur_region.top || pos > cur_region.bottom) { 
        set_cur_region_from_pos(pos);
        add_cur_region_to_toc();
      }
    }

    function set_cur_region_from_pos(pos) {
      region_lookup.forEach(function(header){
        if(pos >= header.top && pos <= header.bottom) {
          cur_region = header
        }
      })
    }

    function add_cur_region_to_toc() {
      header_href = "#" + cur_region.$[0].id
      $('.toc_list').children('a[href="' + header_href +'"]').addClass('active');
      $('.toc_list').children(':not(a[href="' + header_href +'"])').removeClass('active');
    }


  },
}





