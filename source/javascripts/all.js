//= require_tree .
//= require jquery/dist/jquery.js
//= require sticky/jquery.sticky.js

$(function() {

  var navigateToHash = function(hash) {
    var selector = '[name="'+hash+'"]';

    if( $(selector).length !== 0 ) {
      $('html, body').animate({
        scrollTop: $(selector).offset().top
      }, 200);

      return true;
    } else {
      return false;
    }
  };

  $(document).on('click', '.internal-link', function(evt) {
    try {
      var hash =  evt.target.href.split('#')[1];
      if( navigateToHash(hash) ) {
        window.history.pushState({hash: hash}, '', '#'+hash);
        evt.preventDefault();
      }
    } catch(e) {
      // If there are any errors at all, save link functionality.
      return true;
    }
  });

});

$(document).ready(function(){
  $("#site-header").sticky({topSpacing:0});
});
