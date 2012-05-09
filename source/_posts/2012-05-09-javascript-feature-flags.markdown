---
layout: post
title: "Feature Flags in JavaScript"
date: 2012-05-09 14:50
comments: true
categories: 
---

#Introduction

Features Flags (aka feature bits, feature toggles) are a technique where you expose switches in your application which allow you to configure whether certain behavior is enabled or disabled. There are various classes of behavior which you would expose toggles for. Common use cases include hiding user-facing features which are still in development, or switching whether your code uses a new service or an existing service. This allows you to do branch-by-abstraction and avoid long-lived feature branches, which can often be the source of considerable pain.

#Feature Flagging with query strings and css
On a recent project we were releasing to production quite frequently and our team needed to hide new UI features which would take longer to develop than single release cycle. We decided we were happy to hide these features client-side using CSS. To toggle the features on and off we used query strings and some simple javascript.

## the javascript
``` javascript
global.tta ||= {}

splitParam = (param) ->
  result = {}
  tmp = param.split("=");
  result[tmp[0]] = unescape(tmp[1]);
  result

getQueryParameters = ->
  if window.location.search
    # split up the query string and store in an associative array
    params = window.location.search.slice(1).split("&");
    (splitParam param for param in params)

getFeatureFlags = ->
  featureFlags = _.filter getQueryParameters(), (param)-> !!param.ff
  flags = _.pluck featureFlags, 'ff'
  _.map flags, (flag) -> "ff-#{flag}"

global.tta.getFeatureFlags = getFeatureFlags
```









Exposing a feature flag gives you a simple way to control which new parts of your code are exposed within your application, without the need for branching. If you don't know whether everything needed for a new feature will be complete before your next release you can put that feature behind a flag. At the point that you are releasing your software you can toggle the functionality off if it is not complete. Likewise, if you're not sure whether a new service you are using will be available in your next release you can expose a toggle which configures whether your app uses the new service or an existing service. If the service is available and stable by the time you release then you toggle it on, otherwise you simply toggle it off. Without feature flags you would usually use source control to allow you to defer your decision making, creating long-lived feature branches your to do branch-by-abstraction in your codebase, and

The  allows your team to when you have behaviour  By allowing this sort of branch-by-abstraction a software team can avoid long-lived feature branches, which are often the source of considerable pain. In the f
