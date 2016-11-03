TotemLodestar._modules['table_of_contents'] = {
  init: function(id, options) {
    TotemLodestar.load_module(id, this, options)
  },


  smooth_scroll: function(options) {
    speed = options['speed']

    $('a[href^="#"]').on('click', function (e) {
      e.preventDefault();

      var target = this.hash;
      var $target = $(target);

      $('html, body').stop().animate(
        {'scrollTop': $target.offset().top}, 
        speed, 
        'swing', 
        function () {window.location.hash = target;}
      );
    });
  },

  highlight: function(options) {
    ticking    = false;
    regions    = []
    cur_region = null

    build_document_positions();
    check_header_pos(window.scrollY) // Initialize to set the first region active

    window.addEventListener('scroll', function(e){
      if (!ticking) {
        window.requestAnimationFrame(function() {
          check_header_pos(window.scrollY)
          ticking = false;
        });
      }
      ticking = true;
    }) 

    function build_document_positions() {
      $("h1, h2, h3, h4, h5, h6").each(function() { 
        regions.push({ 
          top:    0, 
          bottom: $(this)[0].offsetTop, 
          $:      $(this),
        })
      })

      prev = null
      regions.forEach(function(header){
        if(prev) { header.top = prev.bottom - 1 }
        prev = header
      })
    }

    function check_header_pos(pos) {
      if(cur_region == null || pos < cur_region.top || pos > cur_region.bottom) { 
        set_cur_region(pos);
      }
    }

    function set_cur_region(pos) {
      regions.forEach(function(header){
        if(pos >= header.top && pos <= header.bottom) {
          cur_region = header
        }
      });
     activate_toc_header();

    }

    function activate_toc_header() {
      header_href = "#" + cur_region.$[0].id
      $('.toc_list').children('a[href="' + header_href +'"]').addClass('active');
      $('.toc_list').children(':not(a[href="' + header_href +'"])').removeClass('active');
    }
  },
}





