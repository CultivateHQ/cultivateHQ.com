//= require_tree .
//= require jquery/dist/jquery.js
//= require sticky/jquery.sticky.js

$(function() {

  $(document).on('click', '.internal-link', function(evt) {
    var selector = '[name="'+evt.target.href.split('#')[1]+'"]';

    if( $(selector).length !== 0 ) {
      evt.preventDefault();

      $('html, body').animate({
        scrollTop: $(selector).offset().top
      }, 200);
    } else {
      return true;
    }
  });

});

$(document).ready(function(){
  $("#site-header").sticky({topSpacing:0});
});
