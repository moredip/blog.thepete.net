---
layout: post
title: "introducing rack-flags"
date: 2013-08-24 16:30
comments: true
categories: 
---

I'm pleased to announce [rack-flags](https://github.com/moredip/rack-flags), a very simple way to add [feature flags/bits/toggles](http://martinfowler.com/bliki/FeatureToggle.html) to your Rails app (or any other rack-based web app).

The rack-flags gem allows you to define a set of *feature flags* which can be turned either off or on for any user. Your application code inspects the state of these feature flags when processing a web request and uses that information to modify how it handles that request. 

## A concrete use case

Let's use a concrete example. We're developing a new photo sharing feature for our Web 3.0 application. This is a big project, and we want to be releasing our app to production on a regular basis while the Photo Sharing project is still in progress. To allow that to happen we add an 'expose photo sharing UI' feature flag to our app, which is defaulted to Off while the project is in progress. In our application code we can check for that feature flag and only display a link to the new Photo Sharing section of our UI if the feature is On for the current request. Internal users (product owners, QAs, devs, etc) who want access to the half-finished work do so by overriding the 'expose photo sharing UI' flag to On using an admin UI (a simple rack app that ships with the rack-flags gem). 

Once the first version of Photo Sharing is ready for prime time we simple change the default for the feature flag to On. Now every user has access to the new functionality. After the feature is live for a while and we're confident that it works as advertised we can retire the 'expose photo sharing UI' flag, along with the checks that were added to to the application code.

## The mechanics

The ability to override flags for a given user is achieved using cookies. the rack-flags gem provides a rack app which acts as a simple feature flag admin UI. It lists the flags which have been configured for your app, and allows you to override their default state. Those overrides are stored in the user's cookie. On each request to your web application a small piece of rack middleware inspects that cookie. When your app asks rack-flags whether a feature is turned off or on rack-flags combines the default state of each flag with whatever overrides were detected in the cookie and uses that to tell your application whether the flag is off or on.

## Some code examples

The yaml file which defines the set of feature flags for your app, along with their default state:
```yaml feature_flags.yaml
foo: 
  description: This is my first feature flag
  default: true
show_new_ui: 
  description: render our experimental new UI to the user
  default: false
```

Setting up rack-flags for a rails app:

```ruby application.rb
config.middleware.use RackFlags::RackMiddleware, yaml_path: File.expand_path('../feature_flags.yaml',__FILE__)
```

```ruby routes.rb
mount RackFlags::AdminApp, at: 'some_route'
```

Checking whether a feature is enabled or disabled for a specific request:
```ruby SomeController.rb
  class SomeController < ApplicationController
    def some_action
      features = RackFlags.for_env(request.env)
      @show_whizzy_bits = features.on?(:show_new_ui)
    end
  end
```

That's all there is to it. Check out the [github repo's README](https://raw.github.com/moredip/rack-flags) for more documentation, including an example of setting up a Sinatra app.



## Credits and prior work
This gem is based off of a project myself and some fellow ThoughtWorkers were on at a large online retailer building a Rails-based e-commerce front end. Last time I checked in with them they were still using the original version of this feature flagging system and were very happy with it. 

I [previously blogged about](/blog/2012/11/06/cookie-based-feature-flag-overrides/) the cookie-based approach which we used at that client and subsequenctly re-implemented in this rack-flags gem.

Ryan Oglesby was one of the ThoughtWorkers on that project and co-author of this gem.

A lot of my thinking about feature flags is colored by working with a sophisticated 'feature bit' system several years ago. I believe Sean Ryan was the instigator of that system, which was chiefly implemented by Rob Loh and Elden Bishop under the guidance of of Erik Sowa. Erik and Rob [presented on that feature bit system at Lean Software and Systems Conference 2010](http://www.infoq.com/presentations/Feature-Bits).
