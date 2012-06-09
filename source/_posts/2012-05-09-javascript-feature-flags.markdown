---
layout: post
title: "Feature Flags in JavaScript"
date: 2012-05-09 14:50
comments: true
categories: 
---

On a recent project we were applying Continous Delivery practices and were releasing to production reasonably frequently - sometimes multiple times a week. We didn't want to expose features which were under active development in our production environment but we also wanted to avoid feature branches. I'm going to describe the simple approach we used to solve this problem using *feature flagging* with javascript and CSS.

# What are feature flags?

Features flags (aka feature bits, feature toggles) are a very useful technique for managing latent functionality within your application. You expose switches in your application which configure whether certain behavior is enabled or disabled. Typically your would use this pattern for functionality which is under active development and is not 'fully baked'. 

There are various classes of behavior which you might expose toggles for. Common use cases include hiding user-facing features which are still in development, or switching whether your code uses a new version of a third-party service. This allows you to do branch-by-abstraction and therefore avoid long-lived feature branches which can often be the source of considerable pain to a development team.

## Further reading

For a more in-depth discussion on this pattern, Martin Fowler has a [nice writeup](http://martinfowler.com/bliki/FeatureToggle.html). My former colleague Erik Sowa also has [a nice presentation](http://www.infoq.com/presentations/Feature-Bits) describing how we applied 'feature bits' at a previous company I worked in. Derek Hammer has a [really nice write up](http://www.derekhammer.com/2012/03/24/patterns-to-isolate-code-in-continuous-delivery.html) on the broader range of patterns available for isolating code when practicing Continous Delivery.

#Feature flagging using query strings, javascript and css
As mentioned above, I'll be describing a simple but effective feature flagging technique we used on a recent project.  Our team decided to use feature-flagging to hide new features at the UI level using CSS. The mechanism to toggle the features on and off involved query strings and some simple javascript.

## step 1: extracting feature flags from the query string
First we needed some way to specify whether a feature flag was on or off. We used query params to do this. These query params were totally ignored by the server-side code. There were just there so that javascript on the client side could inspect them at page load.

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
Here we do some simple parsing of `window.location.search` with the help of underscore.js (my favorite javascript library of all time). We find all query params that have a key of 'ff' and return the values in an array. Note that query params may have multiple identical keys; we handle that by representing the parsed key-value pairs as an array of key-value pairs, rather than the simplistic approach of creating a hash table directly from the query string.

## step 2: expose feature flags as classes in the DOM

``` javascript
$(function(){
  _.each( getFeatureFlags(), function(featureFlag){
    $('html').addClass( "ff-" + featureFlag );
  });
});
```

Here we use jQuery to register a function on document ready. This function will grab all the feature flags specified in the query params and then add a class to the doc's `<html>` element for each flag, prepended with 'ff-' to avoid any naming collisions with other CSS classes.


## step 4: show or hide UI elements with CSS

Our goal here is to control whether or not a feature is exposed to an end user. A lot of the time we can hide a feature by simply applying a `display:none` the right DOM element. Because we added our feature flag classes to the root `<html>` element we can apply simple CSS rules like the following:

``` css
.search-wrapper {
  display: none;
}

.ff-search .search-wrapper {
  display: block;
}
```

This will hide the `search-wrapper` element (and anything inside of it) by default, but will show it if there is a parent with a class of `ff-search`. Combined with the javascript above this has the effect that search functionality will be hidden unless you pass in a query params of `ff=search` when loading the page. There we have it, a simple feature-flag.

## Further refinements
This simple approach works quite nicely for a single-page app (which is what our team was developing), but it does have some issues in other cases. The main problem is that any feature flag you specify in a query param will be lost whenever you leave the current page. This could be remedied by storing feature flags in a cookie or in HTML5 local storage. You'd then check for flags in that store in addition to in the query param during page load. Presumably a flag specified in a query param would override anything in the store.

I've only covered using a feature flag to drive CSS changes, but you could easily expose a simple javascript API which would allow developers to plug in different code based on whether a flag was off or on. In sophisticated use cases you would probably use feature flags to drive the initial wiring up of your code's dependencies during boot.
