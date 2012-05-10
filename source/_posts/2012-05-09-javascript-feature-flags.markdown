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

## Step 1: extracting feature flags in the query string
``` javascript
function parseQueryParamPart(part){
  var keyAndValue = part.split("=");
  return {
    key: unescape(keyAndValue[0]),
    value: unescape(keyAndValue[1])
  };
}

// returns an array of {key:"",value:""} objects
function getQueryParamKeyValuePairs(searchSection){
  var params = searchSection.slice(1).split("&");
  return _.map( params, parseQueryParamPart );
}

function getFeatureFlags(){
  var queryParamKeyValuePairs = getQueryParamKeyValuePairs( window.location.search );

  return _.compact( _.map( queryParamKeyValuePairs, function(pair){
    if( pair.key === 'ff' )
      return pair.value;
    else
      return undefined;
    end
  }));
}
```
Here we do some simple parsing of search part of the window.location, with the help of underscore.js. We find all query params that have a key of 'ff' and return the values in an array. Note that query params may have multiple identical keys; we handle that by passing around the parsed key-value pairs as an array of pairs, rather than the naive approach of creating a hash table directly from the query string.

## Step 2: set feature flags as classes in the DOM

``` javascript
$(function(){
  _.each( getFeatureFlags(), function(featureFlag){
    $('html').addClass( "ff-" + featureFlag );
  });
});
```


Exposing a feature flag gives you a simple way to control which new parts of your code are exposed within your application, without the need for branching. If you don't know whether everything needed for a new feature will be complete before your next release you can put that feature behind a flag. At the point that you are releasing your software you can toggle the functionality off if it is not complete. Likewise, if you're not sure whether a new service you are using will be available in your next release you can expose a toggle which configures whether your app uses the new service or an existing service. If the service is available and stable by the time you release then you toggle it on, otherwise you simply toggle it off. Without feature flags you would usually use source control to allow you to defer your decision making, creating long-lived feature branches your to do branch-by-abstraction in your codebase, and

The  allows your team to when you have behaviour  By allowing this sort of branch-by-abstraction a software team can avoid long-lived feature branches, which are often the source of considerable pain. In the f
