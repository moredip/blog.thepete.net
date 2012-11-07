---
layout: post
title: "Cookie-based feature flag overrides"
date: 2012-11-06 18:55
comments: true
categories: 
---

## Introduction

If you're practicing Continuous Delivery then you're probably using Feature Flags to hide half-baked features which are being shipped into production as latent code. It's useful to allow individual users to **manually override** those feature flags so that they can get a preview of these latent features before they are released to everyone. People wanting to do this would be testers, product stakeholders, and external beta testers. 

This is a similar concept to the Canary Releasing approach which organizations like Facebook use to trial new features. The difference is that with manual overrides each individual is opting in for features themselves, as opposed to being place arbitrarily into the pool of users assigned as canaries.

## A lightweight flag override

In the past I've blogged about [manually setting feature flags using query strings](/blog/2012/05/09/javascript-feature-flags/). On my current project we took an alternate approach using cookies instead. It was still a simple lightweight implementation, but rather than specifying an override using query params we instead used a permanent cookie. 

General information about the current set of feature flags in play within our app is stored inside a per-environment configuration file which ships with the rest of our server-side code. This configuration file lists which feature flags are available, along with a brief description of the flag and a default state (on or off).

However in addition to that default server-side state we also allow flags to be overridden via a `feature_flags` cookie. This cookie is a simple JSON document describing which flags should be overridden. Any flag states listed in that cookie's JSON payload will override the default state specified in the environment's feature flag configuration.

## An example

Let's say our production environment's feature flag config looks like this:

``` yaml feature_flags.yaml
enable_chat_feature:
  description: Expose our new experimental chat interface (WIP)
  default: false

use_new_email_service:
  description: Send registration emails using our new email service (still under pilot)
  default: false
```

By default anyone accessing our application will not see the new chat interface which we're still working on because the default state for that feature is _off_. Likewise when someone signs up for a new account they will be sent welcome email using our old creaky email service, rather than the fancy new one that our buddies in a backend service team have been working on.

Now let's say I'm a QA and I want to test whether that email service is ready for prime time. All I need to do is set my `feature_flags` cookie in my browser to something like:

``` javascript feature_flags cookie
{
 "use_new_email_service": true
}
```

Once that cookie is set in my browser then whenever I register a new account using that browser then the application will notice the override, interpret the `use_new_email_service` feature as _on_, and send my welcome email using the new email service. 

## Simple usability improvements

Obviously it's not ideal to have users manually editing raw JSON within a cookie. In our app we added a simple admin-restricted page to our app which listed all known feature flags in the environment and allowed users to view and set which flags were manually overridden using radio buttons with three states - On, Off, or Default. Changing those buttons modified which flag overrides were stored in the cookie JSON. 

This page also highlighted stale flags which no longer existed in the environment but were still set as overridden in the cookie. This is a fairly common occurance if you're retiring your feature flags regularly (which you absolutely should be doing).

## Limitations

This approach is pretty simplistic; there are clearly some limitations. Firstly the overrides are stored client-side. That means you can't restrict which flags are overriden, you can't audit which flags are overridden, and you can't go in as an administrator and modify the overrides. There are obviously also security concerns to be aware of when you're allowing client-side state to impact what happens server-side.

Another issue is that the overrides are per-browser rather than per-user. That means that users have to explicitly configure the overrides for each browser (and mobile device) they access your app with, and remember to keep them in sync. You also need to remember that you're setting the flags for all users that you log in as via that browser, not just the current user. This is probably counter to a lot of people's intuition. However the fact that the overrides aren't tied to a specific user can sometimes be helpful for testing - the registration email example above was actually a good example of that. 

## Wrapping up

All in all this is a nice simple approach to get started along the path of configurable feature flags. An organization that really embraces this idea will probably outgrow this basic approach fairly quickly, but I belive it is a simple way to get started and show the value of feature overrides. If you're using feature flagging but not using overrides currently then I encourage you to consider this approach too.
