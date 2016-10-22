function enable_collapse_sidebar() {
  $('.side-nav_section-header').on('click',function (e) {
    e.preventDefault();
    $(this).parent().toggleClass("collapsed")

    icon = $(this).children()[0]
    if(icon.className == 'fa fa-minus-square') {
      icon.className = 'fa fa-plus-square'
    } else {
      icon.className = 'fa fa-minus-square'
    }
  });
}