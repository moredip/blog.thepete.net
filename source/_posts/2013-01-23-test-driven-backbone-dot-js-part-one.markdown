---
layout: post
title: "Test-driven Backbone.js  - Part One"
date: 2013-01-23 08:02
comments: true
categories: 
---

In this series of posts I'm going to walk through some practical details on how we can develop Backbone.js applications in a test-driven manner. Developing this way leads to better structured applications, as we'll discover.

## Setup

We'll be using backbone and underscore to build a single page app which simulates a card wall. We'll be writing our app and our tests using coffeescript - if there's enough interest I'd be happy to set up a javascript translation of the code snippets - please <a href="mailto:blog@thepete.net">let me know</a>. We'll be  using Jasmine as our test runner and we'll be using sinon.js to create test doubles (mocks and stubs). We'll also use a few other small utilities and plugins as we go.

## Part one - test driven models

Let's start off simple and test-drive a Backbone model which will represent a card on the wall. I like to start off a new test file with a really dumb test that just drives out the intial setup of the class:

``` coffeescript card_spec.coffee
describe Card, ->
  it 'should be defined', ->
    expect( Card ).not.toBeUndefined()
```

Pretty much the simplest test I can think of. Check that `Card` has been defined somewhere. And of course when we run this test it will fail, because we haven't defined that model yet. Let's do that.

``` coffeescript card.coffee
Card = 'slime'
```

OK, with that done our first test is passing. 

I know, I know. We didn't define `Card` to be a backbone model. I'm being a bit dogmatic here for a moment and following the test-driven tenent of doing the Simplest Possible Thing to get the test passing. In this case assigning a string is a simple thing to do, so that's what I did. Using the keyword 'slime' is a trick I picked up from Gary Bernhardt to indicate that this is obviously not finished code.

So, we have a slimed Card instance which passes the test. Our next step is to write a test which drives us to make that Card a real Backbone Model.

``` coffeescript card_spec.coffee
describe Card, ->
  it 'is defined', ->
    expect( Card ).not.toBeUndefined()

  it 'looks like a BB model', ->
    card = new Card
    expect( _.isFunction(card.get) ).toBe(true)
    expect( _.isFunction(card.set) ).toBe(true)
```

This new test verifies that Card instances 'quack like a Model'. Since Javascript doesn't really have a strong notion of 'type', I follow a duck-typing approach here and just verify that the Card instance implements methods that I'd expect a Backbone Model to have. This is good enough to drive us towards a correct implementation of Card.

``` coffeescript card.coffee
Card = Backbone.Model
```

Note that I'm still sticking to the Simplest Possible Thing tenent. We're not expecting Card to have any additional functionality beyond the stuff it gets from Backbone.Model, so I don't bother to use `Backbone.Model.extend`. I've found that when I'm driving out code this way I'm often surprised that I *never* have to go beyond what I thought at the time was a placeholder implementation. I wouldn't be surprised if that holds true here and that we end up never needing to extend Card beyond this vanilla implementation.

## A Card Wall

  Now that we have a Card defined, let's look at building a Wall of cards. There's a temptation here to think 'Oh, a wall of cards is like a collection of cards Let's define it as a Backbone.Collection'. That's a bad idea here. A card Wall does *contain* a collection of cards, but it will likely also have other attributes. It might have a title, and an owner maybe. I've found that with Backbone if you're modeling an entity in your system that's more than just a collection then it's best to represent that entity as a Backbone.Model which *contains* a Backbone.Collection as an attribute, rather than as a straight Backbone.Collection.

Given that, let's test-drive a CardWall which contains a collection of Cards. Again we'll start off really simply.

``` coffeescript card_wall_spec.coffee
describe CardWall, ->
  it 'is defined', ->
    cardWall = new CardWall
    expect( cardWall ).not.toBeUndefined()
```

This test will fail because we haven't defined a CardWall anywhere. Let's get it to pass.

``` coffeescript card_wall.coffee
CardWall = Backbone.Model
```

That gets our tests back to green. 

Note that I'm drifting a little away from my previous Simplest Possible Thing dogmatism. I know that I'm going to be making a Backbone.Model, and I'm gaining a bit more confidence in my workflow here, so I'm going to start taking slightly bigger TDD steps and define CardWall as a Backbone.Model even though the test isn't strictly requiring that. 

Taking bigger TDD steps like this is OK, as long as we're in the habit of slowing down and taking smaller steps as soon as we start feeling uncomfortable. A good rule of thumb is that if your stuck in the Red part of your TDD cycle for more than a few minutes then you're probably taking too big a step and should dial it back. Kent Beck has a good discussion about this in a QCon talk from a few years ago. Hey, if Kent bends the TDD rules sometimes then we're allowed to too.

OK, now let's drive out that cards collection we discussed earlier.

``` coffeescript card_wall_spec.coffee
describe CardWall, ->
  it 'is defined', ->
    cardWall = new CardWall
    expect( cardWall ).not.toBeUndefined()

  it 'has a collection of cards', ->
    cardWall = new CardWall
    expect( cardWall.has('cards') ).toBe(true)
    expect( cardWall.get('cards').models ).toBeDefined()
```

We're checking that our card wall has a `cards` attribute, and then we're checking that the `cards` attribute looks like a Backbone.Collection by checking that is has a models property. Let's get this passing.

``` coffeescript card_wall.coffee
Cards = Backbone.Collection 

CardWall = Backbone.Model.extend
  defaults:
    cards: new Cards
```

This is a pretty big step. We've defined a `Cards` collection, and we've extended our CardWall model to have an instance of that collection as a `cards` attribute  by default.

Our tests are green again, but instead of moving on to our next test I'm going to take a moment to refactor. It's really easy to forget the Refactor part of the Red-Green-Refactor cycle but it is almost the most important part if you want TDD to drive you towards cleaner code. I'm going to DRY up our card wall tests a little bit.

``` coffeescript card_wall_spec.coffee
describe CardWall, ->
  cardWall = null
  beforeEach ->
    cardWall = new CardWall

  it 'is defined', ->
    expect( cardWall ).not.toBeUndefined()

  it 'has a collection of cards', ->
    expect( cardWall.has('cards') ).toBe(true)
    expect( cardWall.get('cards').models ).toBeDefined()
```

All I've done here is pull out a shared cardWall instance and set it up in a beforeEach. A small change, but it reduces some duplication from the tests and makes them a little bit easier to read.

What's next? Let's give the CardWall a title attribute, and have it default to something sensible.

``` coffeescript card_wall_spec.coffee
describe CardWall, ->
  cardWall = null
  beforeEach ->
    cardWall = new CardWall

  # ... other tests here ...

  it 'has a default title', ->
    expect( cardWall.get('title') ).toBe( 'Card Wall' )

```

And let's get that test to pass:

``` coffeescript card_wall.coffee
Cards = Backbone.Collection 

CardWall = Backbone.Model.extend
  defaults:
    cards: new Cards
    title: 'Card Wall'
```

And we're back to green.

