# Cultivate HQ Website

This is the codebase for the Cultivate website. We use middleman to generate a static website.

## Setting up

middleman is a ruby-based site generator, however there are javascript dependencies using bower.
You'll need to make sure you have node and npm installed.

    git clone git@github.com:CultivateHQ/cultivateHQ.com.git
    cd cultivateHQ
    bundle
    npm install bower -g
    middleman server

All being well, you'll have a server running on [localhost - port 4567](http://0.0.0.0:4567)

## Publishing Changes

Once your ready to push changes to the live website, run:

    middleman deploy

This will build the project and deploy it to the cultivatehq.github.io repository


## Layout Styling

There are different layouts across each part of the Cultivate website. These are broken down as far as possible into modules.

Usually, just taking a look at another page and cloning it will be enough for you to get the right classes for the right layout, but below are some use case examples.

Aside from the blog posts, all pages will need HTML tweaks to keep the desired look and feel.

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

