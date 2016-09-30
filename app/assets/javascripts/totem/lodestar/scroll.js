// ticking     = false;
// header_objs = []
// cur_region  = null

// $(function(){
//   set_document_positions()
// })

// function set_document_positions() {
//   headers = $("h1, h2, h3, h4, h5, h6")
//   headers.each(function(i){
//     header_objs.push({$: $(this), region: {bottom: $(this)[0].offsetTop}});
//   }, this)

//   prev = null
//   header_objs.forEach(function(header){
//     if(prev)
//       header.region.top = prev.region.bottom - 1
//     else
//       header.region.top = 0
//     prev = header
//   })
//   console.log(header_objs)

// }

// window.addEventListener('scroll', function(e){
//   last_known_scroll_position = window.scrollY;
//   if (!ticking) {
//     window.requestAnimationFrame(function() {
//       check_header_pos(last_known_scroll_position)
//       ticking = false;
//     });
//   }
//   ticking = true;
// })

// function check_header_pos(pos) {
//   console.log(pos)
//   header_objs.forEach(function(header){
//     if(pos >= header.region.top && pos < header.region.bottom)
//       console.log('In current region of ', header.$[0])
//   })
// }


// $(function(){
//   // set_document_positions()
//   enable_smooth_scrolling()
// })


function enable_smooth_scrolling() {
  $('a[href^="#"]').on('click',function (e) {
    e.preventDefault();

    var target = this.hash;
    var $target = $(target);

    $('html, body').stop().animate({
        'scrollTop': $target.offset().top
    }, 250, 'swing', function () {
        window.location.hash = target;
    });
  });
}