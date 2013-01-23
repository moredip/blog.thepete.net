---
layout: post
title: "Deploying to Heroku from CI"
date: 2013-01-21 21:17
comments: true
categories: 
---

If you're working on top of a modern web stack then the [Heroku](http://www.heroku.com/) hosting platform is a compelling option for standing up an instance of your app with what is usually a trivial amount of effort. No need to provision EC2 servers, write chef recipes, or mess with deploy tools. Just run a couple of commands in the shell and then `git push heroku`. 

## Heroku as a staging environment
This makes Heroku a compelling choice for hosting a staging environment for your application. Staging environment contains the latest 'good' build of your app. They are used for things like automated acceptance testing, manual QA, story sign-off, or internal demos.  

Hooking up an automatic staging environment deploy to the end of a CI run is a nice way of ensuring that your staging environment always contain the freshest good build of your app.

## Headless Heroku deploys are fiddly
Unfortunately Heroku's tooling isn't really optimized for deploying from a CI agent - sometimes referred to as *headless* deployment. Heroku is really geared towards deployment from a developer or operator workstation. It expects you to have an SSH key registered with Heroku before deploying, and to have a heroku remote configured in the local git repo you're deploying from. That's a very reasonable assumption for a developer working on an app, but it's not so reasonably for a CI agent. A CI agent may well be building multiple different apps, and often clears out things like git repos between builds. In the extreme case there are hosted tools like [Travis CI](https://travis-ci.org/) where each build of your app takes place on essentially a totally fresh box, with no ability to pre-configure things like SSH keys.

This isn't an insurmountable problem. It is *possible* to deploy from a git commit to Heroku in these circumstances. It's just a bit of a hassle to figure out. But luckily for you I've figured it out on your behalf, and even released a ruby gem which does the work for you.

## gem install heroku-headless

This gem grew out of me setting up Travis to deploy to a Heroku app after each successful CI build. After getting it working I distilled the relevant magic into the heroku-headless gem.

Using it is as simple as:

``` ruby travis-after-script
require 'heroku-headless'
HerokuHeadless::Deployer.deploy( 'your-app-name' )
```

This script will deploy the commit you currently have checked out in your local repo to the Heroku app name you specify. The only other setup needed for that script is to have a `HEROKU_API_KEY` environment variable set, where the user associated with that api key is registered as a collaborator on the Heroku app you're deploying to. Obviously Heroku doesn't let random people just deploy arbitrary code to an app.

If you register a script like the one above as an after-script in your Travis setup then that Heroku app will always be running the last successful build of your application. Very handy for acceptance tests, manual QA, or showcasing.

## Keep that API key secret
That Heroku API key should be considered a very private secret unless you want someone running up a huge bill on your Heroku account. I would advise not checking that key into source control. Using something like Travis's [secure environment variables](http://about.travis-ci.org/docs/user/build-configuration/#Secure-environment-variables) is a good way to get that secret injected into your build scripts without exposing it to prying eyes.

## Bonus Feature: disposable apps

While building out the functionality in heroku-headless I also experimented with the creation of disposable apps. The concept there is that you might want to create an entirely new Heroku app, deploy to it, run some tests, and then delete the app entirely. I never ended up using this functionality, but it's in the gem. To use it you'd do something like:

``` ruby deploy-to-disposable-app
require 'heroku-headless/disposable_deployer'
HerokuHeadless::DisposableDeployer.new.go
```

## UPDATE: Behind the curtain
I wrote a [follow up post](/blog/2013/01/22/deploying-to-heroku-from-ci-the-gory-details/) to this one which describes how the heroku-headless gem actually works. Check that out if you're interested in the gory details.
