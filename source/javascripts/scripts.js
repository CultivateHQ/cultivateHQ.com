$(function() {

    $( '#mobile-menu-trigger' ).on( 'click', function (e) {
      e.preventDefault();
      $( 'body' ).toggleClass('mobile-menu-on');
    });

  });
