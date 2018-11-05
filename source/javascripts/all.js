import Slideout from 'slideout';

$(function() {
  var slideout = new Slideout({
    'panel': document.getElementById('panel'),
    'menu': document.getElementById('menu'),
    'padding': 200,
    'tolerance': 70,
    'side': 'right'
  })

  slideout.disableTouch();

  document.querySelector('#menu-button').addEventListener('click', function() {
    slideout.toggle();
  });
});

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
  // $("#site-header").sticky({topSpacing:0});

  // Removed Modernizr for this line which checks for SVG compatibility
  if(!(document.createElementNS && document.createElementNS('http://www.w3.org/2000/svg','svg').createSVGRect)) {
    $('img[src*="svg"]').attr('src', function() {
      return $(this).attr('src').replace('.svg', '.png');
    });
  }

  // Hover events for touch devices
  $('.services-link, #site-navigation a, .page-content a, .button').bind('touchstart touchend', function() {
      $(this).toggleClass('hover');
  });

  // IE9 (or less) detection
  if ( ie9 ) {
    $("body").addClass("ie9");
  }

  if ( $('body').is('.ie9') ) {
    $('[placeholder]').focus(function () {
    var input = $(this);
    if (input.val() === input.attr('placeholder')) {
        input.val('');
        input.removeClass('placeholder');
    }
    }).blur(function () {
        var input = $(this);
        if (input.val() === '' || input.val() === input.attr('placeholder')) {
            input.addClass('placeholder');
            input.val(input.attr('placeholder'));
        }
      }).blur().parents('form').submit(function () {
      $(this).find('[placeholder]').each(function () {
          var input = $(this);
          if (input.val() === input.attr('placeholder')) {
              input.val('');
          }
      });
    });
  }
});
