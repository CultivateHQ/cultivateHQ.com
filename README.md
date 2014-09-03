# Cultivate HQ Website

This is the codebase for the Cultivate website. We use middleman to generate a static website.

## Setting up

    git clone git@github.com:CultivateHQ/cultivateHQ.com.git
    cd cultivateHQ
    bundle
    middleman server

All being well, you'll have a server running on [localhost - port 4567](http://0.0.0.0:4567)

## Publishing Changes

Once your ready to push changes to the live website, run:

    middleman deploy

This will build the project and deploy it to the cultivatehq.github.io repository
