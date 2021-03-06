// Write out the blockquote template
document.write('<blockquote style="opacity:0" class="testimonial-quote testimonial-quote--home"><span class="testimonial-quote__inner"></span><cite class="testimonial-quote__left"><img class="testimonial-fill-image" src="" /></cite></blockquote>');

$(document).ready(function(){
  // Load a random testimonial on page load from this array
  var testimonials = [{
    quote: "The team at Cultivate combine the best of agile software delivery with an in-depth knowledge of product development. It's hard to find a team as experienced and passionate as they are.",
    cite: "Evan Henshaw-Plath<br> Co-creator, Twitter",
    image: "/images/testimonials/large/evan-henshaw-plath.jpg"
  }, {
    quote: "I’ve worked with the folks at Cultivate first hand. While they excel at agile product development, where they really shine is in striving to continually understand changing client and customer needs and incorporating those learnings, in real time, into their work. This results not only in products built and designed well but also ones that demonstrably impact their clients' businesses.",
    cite: "Jeff Gothelf<br>Author Lean UX",
    image: "/images/testimonials/large/jeff-gothelf.jpg"
  }, {
    quote: "In every project I worked with Cultivate on, they always found opportunities to exceed expectations.  I only hope that I get to work with other development companies that are as talented, professional and easy to work with.",
    cite: "Alastair Williamson-Pound<br>Senior Product Manager, Money Advice Service",
    image: "/images/testimonials/large/alastair-williamson-pound.jpg"
  }];

  // Calculate array length and pick a random number from that length
  var randomTestimonial = Math.floor(Math.random() * testimonials.length)

  // Fill up the blockquote
  $( '.testimonial-quote__inner' ).html( testimonials[randomTestimonial].quote );
  $( '.testimonial-quote__left' ).html(testimonials[randomTestimonial].cite);
  $( '.testimonial-quote__left' ).prepend( '<img src="' + testimonials[randomTestimonial].image + '" />' );

  // Fade up the blog quote, with a little timeout to account for load.
  setTimeout(function(){
    $( '.testimonial-quote--home' ).css('opacity','1');
  }, 500);

});
