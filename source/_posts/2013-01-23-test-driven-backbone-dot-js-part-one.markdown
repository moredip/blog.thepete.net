---
layout: post
title: "Test-driven Backbone.js  - Part One"
date: 2013-01-23 08:02
comments: true
categories: 
---

In this series of posts I'm going to walk through some practical details on how we can develop Backbone.js applications in a test-driven manner. Developing this way leads to better structured applications, as we'll discover.

## Setup

We'll be using backbone and underscore to build a single page app which simulates a card wall. We'll be writing our app and our tests using coffeescript. If there's enough interest I'd be happy to set up a javascript translation of the code snippets - please <a href="mailto:blog@thepete.net">let me know</a>. We'll be  using Jasmine as our test runner and we'll be using sinon.js to create test doubles (mocks and stubs). We'll also use a few other small utilities and plugins as we go.

## Part one - test driven models

Let's start off simple and test-drive a Backbone model which will represent a card on the wall. I like to start off a new test file with a really dumb test that just drives out the intial setup of the class:

``` coffeescript card_spec.coffee
describe Card, ->
  it 'is defined', ->
    expect( Card ).not.toBeUndefined()
```

Pretty much the simplest test I can think of: check that `Card` has been defined somewhere. Of course when we run this test it will fail, because we haven't defined that model yet. Let's do that.

``` coffeescript card.coffee
Card = 'slime'
```

OK, with that done our first test is passing. 

I know, I know. We didn't define `Card` to be a backbone model. I'm being a bit dogmatic here for a moment and following the test-driven tenent of doing the Simplest Possible Thing to get the test passing. In this case defining Card as a string is a simple thing to do, so that's what I did. Using the keyword 'slime' is a trick I picked up from Gary Bernhardt to indicate that this is obviously not finished code.

So, we have a slimed Card definition which passes the test. Our next step is to write a test which drives us to make that Card a real Backbone.Model.

``` coffeescript card_spec.coffee
describe Card, ->
  it 'is defined', ->
    expect( Card ).not.toBeUndefined()

  it 'looks like a BB model', ->
    card = new Card
    expect( _.isFunction(card.get) ).toBe(true)
    expect( _.isFunction(card.set) ).toBe(true)
```

This new test verifies that Card instances 'quack like a Model'. Since JavaScript doesn't really have a strong notion of type I follow a duck-typing approach here and just verify that the Card instance implements methods that I'd expect a Backbone Model to have. This is good enough to drive us towards a correct implementation of Card:

``` coffeescript card.coffee
Card = Backbone.Model
```

Note that I'm still sticking to the Simplest Possible Thing tenent. Our test doesn' expect Card to have any additional functionality beyond the stuff it gets from Backbone.Model, so I don't bother to use `Backbone.Model.extend`. When I'm driving out code this way I'm often surprised that I *never* have to go beyond what I thought at the time was a placeholder implementation. I wouldn't be surprised if that holds true here and that we end up never needing to extend Card beyond this vanilla implementation.

## A Card Wall

  Now that we have a Card defined, let's look at building a Wall of cards. There's a temptation here to think 'Oh, a wall of cards is like a collection of cards; let's define it as a Backbone.Collection'. That's a bad idea here. A card wall does *contain* a collection of cards, but it will likely also have other attributes. It might have a title, and an owner maybe. I've found that with Backbone if you're modeling an entity in your system that's more than just a collection then it's best to represent that entity as a Backbone.Model which *contains* a Backbone.Collection as an attribute, rather than modelling as a Backbone.Collection with additional custom properties.

Given that, let's test-drive a `CardWall` which contains a collection of `Cards`. Again we'll start off really simply:

``` coffeescript card_wall_spec.coffee
describe CardWall, ->
  it 'is defined', ->
    cardWall = new CardWall
    expect( cardWall ).not.toBeUndefined()
```

This test will fail because we haven't defined `CardWall` anywhere. Let's get it to pass:

``` coffeescript card_wall.coffee
CardWall = Backbone.Model
```

That gets our tests back to green. 

Note that I've drifting a little from my previous Simplest Possible Thing dogmatism. I know that I'm going to be making a Backbone.Model, and I'm gaining a bit more confidence in my workflow here, so I'm going to start taking slightly bigger TDD steps and define CardWall as a Backbone.Model even though the test isn't strictly requiring that. 

Taking bigger TDD steps like this is OK, as long as we're always ready to slow down and taking smaller steps if we start feeling uncomfortable with our code. A good rule of thumb is that if you're stuck in the Red part of your TDD cycle for more than a few minutes then you're probably taking too big a step and should dial it back. Kent Beck has a good discussion about this in a QCon talk from a few years ago. Hey, if Kent bends the TDD 'rules' sometimes then we're allowed to too.

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

We're checking that our card wall has a `cards` attribute, and then we're checking that the `cards` attribute looks like a Backbone.Collection by checking that is has a `models` property. Let's get this passing:

``` coffeescript card_wall.coffee
Cards = Backbone.Collection 

CardWall = Backbone.Model.extend
  defaults:
    cards: new Cards
```

This is a pretty big step. We've defined a `Cards` collection, and we've extended our `CardWall` model to have an instance of that collection as a `cards` attribute  by default.

Our tests are green again, but instead of moving on to our next test I'm going to take a moment to refactor. It's really easy to forget the Refactor part of the Red-Green-Refactor cycle but it is almost the most important part if you want TDD to drive you towards cleaner code. I'm going to DRY up our card wall tests a little bit:

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

All I've done here is pull out a shared `cardWall` variable and set it up in a `beforeEach` function. A small change, but it reduces some duplication from the tests and makes them a little bit easier to read.

What's next? Let's give the CardWall a title attribute, and have it default to something sensible:

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

## Adding cards to a card wall

We are going to want to add `Card` instances to our `CardWall`. A client of CardWall could do that now by doing something like `cardWall.get('cards').add( cardProperties )`, but that's not a nice approach. It's ugly to read and is a Law of Demeter violation which exposes the internals of the CardWall a bit too much. Let's expose a method on CardWall that hides those details. Here's a test describing what we want the method to do:

``` coffeescript card_wall_spec.coffee
describe CardWall, ->
  cardWall = null
  beforeEach ->
    cardWall = new CardWall

  # ... other tests here ...

  it 'can add cards to the cards collection', ->
    cardWall.addCard( text: 'new card text' )

    addedCard = cardWall.get('cards').at(0)
    expect( addedCard.get('text') ).toBe('new card text')
```

We expect to be able to call an `addCard` method which will add a card to the cards collection with the appropriate attributes. We can get that test passing with a one-line method:

``` coffeescript card_wall.coffee
Cards = Backbone.Collection 

CardWall = Backbone.Model.extend
  defaults:
    cards: new Cards
    title: 'Card Wall'

  addCard: (attrs)->
    @get('cards').add( attrs )
```


## Testing events

Clients of our CardWall model are going to want to know when cards are added to our wall. By default a Backbone model only fires a change event when one of its attributes are re-assigned, not when one of its attributes are changed internally. That means that a client which has subscribed to changes on a `CardWall` instance won't be notified when its cards collection changes. Let's confirm that problem via a test:

``` coffeescript card_wall_spec.coffee
describe CardWall, ->
  cardWall = null
  beforeEach ->
    cardWall = new CardWall

  # ... other tests here ...

  it 'fires a change:cards event when a card is added', ->
    eventSpy = sinon.spy()
    cardWall.on('change:cards',eventSpy)
    cardWall.addCard()
    expect( eventSpy.called ).toBe(true)
```

We're creating a Sinon spy function, and asking our cardWall to call that spy function whenever a `change:cards` event occurs. We then add a card to the cardWall and then check whether our spy has been called. If the spy was called then that event has indeed been published.

As expected, this test fails because a Model doesn't automatically notify subscribers of changes *inside* its attributes. However we can get the test to pass pretty simply:

``` coffeescript card_wall.coffee
Cards = Backbone.Collection 

CardWall = Backbone.Model.extend
  defaults:
    cards: new Cards
    title: 'Card Wall'

  addCard: (attrs)->
    @get('cards').add( attrs )
    @trigger('change:cards')
```

We've added a `trigger` call at the end of our `addCard` method. This will fire off the expected event whenever we add a card. With that change our tests are back to green, and we're at a good point to wrap up this installment.

## What have we covered

So what did we cover in this installment?

We've learned the basics of how to test-drive a Backbone model. We've learned that we should strive to get tests passing by doing the Simplest Possible Thing, but that we don't need to be to dogmatic about that. We've discovered that a Backbone.Collection is only approriate for modelling a pure collection of items. We've seen that it's better to encapsulate access to internal attributes by using helpful functions like `addCard`. Finally we've seen how to use Sinon spies to test basic Backbone event publication.

## No DOM, no jQuery

One final thing to note before we wrap up - we have not made any reference to the DOM in these tests. In fact, when developing this code I ran my tests within node.js. This is a very important point, and a key property of a well-structured Backbone application - Views should be the only thing referencing the DOM (and also the only thing accessing JQuery's almighty $). 

The flip side of keeping the DOM and jQuery contained without our Views is that we should always strive to keep our Backbone Views as skinny and logic-free as possible. Because Views interact with the DOM they are particularly tricky to test, and our tests are slower to run because we have to run them in a browser. 

In the next installment we dive into testing Backbone Views, and also go into more details on what a View's responsibilities should be.
