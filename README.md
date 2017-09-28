# Cultivate HQ Website

This is the codebase for the Cultivate website. We use middleman to generate a static website.

## Setting up

middleman is a ruby-based site generator, however there are javascript dependencies using bower.
You'll need to make sure you have node and npm installed.

    git clone git@github.com:CultivateHQ/cultivateHQ.com.git
    cd cultivateHQ
    bundle
    npm install bower -g
    bundle exec middleman server

All being well, you'll have a server running on [localhost - port 4567](http://0.0.0.0:4567)

## Publishing Changes

Once your ready to push changes to the live website, run:

    bundle exec middleman deploy

This will build the project and deploy it to the cultivatehq.github.io repository


## Layout Styling

There are different layouts across each part of the Cultivate website. These are broken down as far as possible into modules.

Usually, just taking a look at another page and cloning it will be enough for you to get the right classes for the right layout, but below are some use case examples.

Aside from the blog posts, all pages will need HTML tweaks to keep the desired look and feel.

### Shout outs

If you want to create a "Shout out" panel, with the larger text (see About Us) as an example.

You can use this code to create a shout out div...

	<div class="shout-out">
      <p>Content in here</p>
    </div>
    
If you want a div with a line divider under it, add the `divider` class...

    <div class="shout-out divider">
      <p>Content in here</p>
    </div>
    
Both of these divs must be in inside a `page-layout` div for the font sizes and links to work properly.

e.g.

	<div class="page-content min-width padding-large">
	  <div class="shout-out divider">
        <p>Content in here</p>
      </div>
	</div>
	
### Blog Posts	

For blog posts, I've kept it backwards compatible with all of the posts, code snippets work in the same way and so does the use of 

	<section class="callout">
		Content in here
	</section>
	
Which gets put in a little grey box.

### Full Width content

In order to get a full width rows, you need to break the content div. For example, they should be a outer div and an inner div, one for the page layout one to set a minimum width, so you'd close those off then insert your row or testimonial code

#### Row

	<div class="row row--image-feature">IMAGE</div>
	
#### Testimonial
	<blockquote class="testimonial-quote-macro">
   	 <div class="min-width">
    	<div class="testimonial-quote__image">IMAGE</div>
     	 Quote
     	 <cite>Cite</cite>
   	   </div>
  	</blockquote>	
  	
 Then you'll need to re-open the page layout divs again e.g.
 
 	<div class="page-content padding-large-top">
    	<div class="min-width">
    	Content
    	</div>
    </div>
    
  	
       	