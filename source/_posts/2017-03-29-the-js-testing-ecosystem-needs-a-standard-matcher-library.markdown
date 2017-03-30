---
layout: post
title: "The JS testing ecosystem needs a standard matcher library"
date: 2017-03-29 09:57
comments: true
categories: 
---

### Matchers when making assertions

Unit-testing JavaScript code means making assertions about the shape of things. We make simple assertions like `expect(result).to.eql("SUCCESS")` all the time. We often make slightly more complex assertions like `expect(result).to.have.property('resultType','SUCCESS')` or `expect(result.count).to.be.above(0)`. Some tools allow us to make even more sophisticated assertions like:
```
expect(result).toMatchObject({
  resultType: 'SUCCESS',
  message: 'game saved',
  referenceCode: referenceCodeSentToServer
});

```
The general pattern here is we're passing a **matcher** to an assertion. We're saying "I expect this thing to **match** this specification". The most common form of match is equality, but we also say things like "I expect this thing to contain this property with this specific value", or "I expect this thing to contain these properties, but maybe additional properties that I don't care about".

### Matchers when configuring mocks

Sometimes we create mock functions when testing, either using a mocking library such as sinon.js or testdouble.js, or using the built-in capabilities that come with frameworks like Jest and Jasmine. When configuring mock functions we also use the concept of matchers, in a slightly different way. We might say `callback.withArgs(12,'foo').returns(true)`, which means "when this function is called with the arguments `12` and `'foo'`, return `true`". Same general *matcher* concept - "when we see a set of arguments that **match** these specifications, return this value". 

Sometimes we need to loosen up our configuration and say "when this function is called with anything at all as the first argument and `'foo'` as the second argument, return `true`". That's where being able to apply that generalized *matcher* concept and apply it in this new context of configuring mock functions becomes really handy.

I can also think of a third context where it's nice to have a generalized concept of matchers - testing async code which returns promises. A typical approach might be:
```
doTheThing().then(function(result){
  expect(result).to.eql("SUCCESS");
});
```
This gets a little clunky, so [some tools](http://chaijs.com/plugins/chai-as-promised/) enable us to instead say things like:
```
expect(doTheThing).to.eventually.equal("SUCCESS");
```

That's nice, but what if we have more complex assertions on that result. We're often forced back to something clunky:
```
doTheThing().then(function(result){
  expect(result).to.have.property('resultType','SUCCESS');
  expect(result).to.have.property('message');
});
```

## Problem #1 - Learning multiple APIs

Today every testing tool that does matching does it with its own unique implementation. That means that even if you always use the same testing stack you'll still end up using two matcher implementations - one for your test assertions and one in your mock configurations. If you move between testing stacks frequently then you have it even worse. And that's likely, given that we work in a somewhat fragmented community where React peeps do it one way, Angular peeps another, and server-side peeps 3 additional ways.

This means that you need to hold learn and remember multiple matcher APIs as you move between codebases. And of course they're often implemented using cute DSLs which usually target readability over intuitive write-ability.

## Problem #2 - Generalized extensions aren't possible

Let's say I write a bunch of tests against an API client. I'm sick of writing tests like this:
```
  const requestedUrl = url.parse(fetchMock.lastUrl());

  expect(requestedUrl).toHaveProperty('host','api.bart.gov');
  expect(requestedUrl).toHaveProperty('pathname','/api/etd.aspx');

  const query = querystring.parse(requestedUrl.query);
  expect(query).toHaveProperty('cmd','etd');
  expect(query).toHaveProperty('key');
  expect(query).toHaveProperty('orig','some-abbr');
```

Instead I want to create an extension to my testing tooling so I can write something along the lines of:
```
  expect(fetchMock.lastUrl()).matches(
    aUrl()
      .withHost('api.bart.gov')
      .withPath('/api/etd.aspx')
      .includingQueryParams({
        cmd: 'etd',
        key: anyString(),
        orig: 'some-abbr'
      })
  );
```  
I might well want to also use a similar abstraction to configure a mock function - "when you're called with a URL where the query parameter `cmd` is `etd`, return a list of ETDS. When you're called with a query parameter `cmd` of `stations`, return a list of stations". Unfortunately since every tool uses its own matcher implementation I would get very litte code reuse between those two extensions.

More generally, if I wanted to share this extension with the world as a little open source library it would only be targeted at one specific testing tool. My dream of creating the One True URL Matcher module will never become a reality. The marketplace for sharable extensions to a matcher is so fragmented that it's unlikely that any one library will gain traction.

## Problem #3 - A lack of true composability

Because it's just one feature of a broad tool the API for matching doesn't get as much thought as it could. Most (all?) of the popular tools miss out on a key feature of a matcher API - composability. If we treat a matcher as a first class concept - a specification that a value either matches or does not - then we can start composing matchers together. We can create the intersection of two matchers: "the value must be both `greater than 0` AND `less than 10`". We can create the union between two matchers: "the value must be either `a string` OR `false`". We can parameterize matchers with matchers. We can create an `every` matcher that specifies that every element in a collection matches some specified matcher: "every element in this array must be greater than 50". We could also say "at least one element in this array must have an `id` property of `12`". 

This is a huge win in terms of expressivity. Our tests become a lot more declarative, and our assertion failure messages suddenly have a load more context. For our last example if we're using a composable matcher library our out of the box error message could be "Expected at least one element in the following collection to match: have a property `id` with the value `12`, but none did". Imagine what the error message would be with a hand-rolled check for the same assertion. Probably something like "expected 0 to be greater than 0". 

## "It's like Promises, but for matching things"

This is very similar to the lift we got with Promises. Promises took a *concept* - an async operation with an errback and a callback - and turned it into a concrete thing you could work with in code via a standardized API. That meant we could start composing these things together - e.g. `Promise.all()`- and we could start writing libraries that extended their capabilities - e.g. instrumenting a promise with logging, building coroutine implementations. By formalizing the concept of a matcher we can create a standard API for a general concept and start sharing innovations and tooling built on top of it. 

The road to a standardized Promises API started with Q (I think?), and became generalized via the [Promises/A+](https://promisesaplus.com/) spec. I'm certainly not proposing that we should shoot for a standardized spec for matchers, but I think if we created a high-quality standalone matcher library and made it easy to plug into the existing test ecosystem then we could see some big wins.
