# Cultivate HQ Website

This is the codebase for the Cultivate website. We use middleman to generate a static website.

## Setting up

middleman is a ruby-based site generator, however there are javascript dependencies using bower.
You'll need to make sure you have node and npm installed.

    git clone git@github.com:CultivateHQ/cultivateHQ.com.git
    cd cultivateHQ
    bundle
    npm install bower -g
    bower install
    middleman server

All being well, you'll have a server running on [localhost - port 4567](http://0.0.0.0:4567)

## Publishing Changes

Once your ready to push changes to the live website, run:

    middleman deploy

This will build the project and deploy it to the cultivatehq.github.io repository
