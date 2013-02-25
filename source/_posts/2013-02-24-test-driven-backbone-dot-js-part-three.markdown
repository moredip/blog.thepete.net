---
layout: post
title: "Test-driven Backbone.js - Part Three"
date: 2013-02-24 21:04
comments: true
categories: 
---

In the [previous](/blog/2013/01/23/test-driven-backbone-dot-js-part-one/) [posts](/blog/2013/01/23/test-driven-backbone-dot-js-part-two/) in this series we've done some test-driven development of Backbone Models, Collections, and Views. In this post I'm going to cover another role which I believe should be present in most <abbr title="Single Page App">SPA</abbr> Backbone apps: Controllers. 

## Controllers in a Backbone app
There's nothing in the Backbone.js library for building Controllers. There's not Backbone.Controller for you to extend from. But that doesn't mean that Controllers don't have a part to play in your Backbone app. I suspect that the reason we don't see Backbone.Controller in the library is simply because there isn't much helpful shared functionality that could be put there. The Controller role is more loosly defined than other more concrete roles such as View or Model and so there's not a need for a concrete base implementation in the Backbone.js library. However that does *not* mean that your app wouldn't benefit from code organized under the the Controller role.

## No Controller class or prototype
Since we don't need any shared functionality we won't need to use any inheritance (neither prototypical nor pseudo-classical) when building our controller. So I'm going to create controllers using simple [constructor functions](/blog/2012/02/06/class-less-javascript). I favor constructor functions over inheritance heirarchies whenever possible - I think they're a better fit with the 'good parts' of JavaScript - so that's what we'll use here.

## What does a Controller do?

Simply put, a controller mediates between the UI and the rest of your application. In the case of a Backbone app this generally means reacting to events published from your View layer. A controller may respond to these events by updating Model instances, or by making calls to Services (which we'll get to later on).

## Doesn't a View do that?

In a lot of Backbone application that *don't* have Controllers in their code you see Backbone Views that do a lot of the coordination work. Rather than just acting as a translation layer between the UI and the rest of the application these **Fat Backbone Views** take on additional responsibilities, often acting as Controllers too. These views tend to be large, unwieldy, tough to test. Their implementations are hard to read and hard to maintain. They cause these issues because they are violating the Single Responsibility Principle. Introducing a Controller helps avoid this situation. Views can remain focussed on their single responsibility - mapping between the UI and the application. Controllers take on the additional responsibilities which would otherwise muddy the View's role.


## Adding new cards to a card wall

When we left off our Cards application in our last post we had a 'CardWall' model which represented a set of cards. We also had a 'NewCardView' which allowed a user to enter a new card. However what's missing is to tie those two elements together. When a user fills out the text for a new card and hits create then a new card should be added to the CardWall. This is exactly the place where a Controller would come into play - bridging between a View and a Collection or Model (or both). 

So, let's get going and use tests to drive out that controller.

## Implementation

Once again, we'll start of for a silly-simple test to get us started. We'll test that we can create a controller:

``` coffeescript main_controller_spec.coffee
describe 'main controller', ->
  it 'can be created', ->
    controller = createMainController()
    expect( controller ).toBeDefined()
```

This will fail because we don't have that constructor function defined yet. We easily remedy that and get our test back to green:

``` coffeescript main_controller.coffee
createMainController = ()->
  {}
```

Simple enough. A function that takes no parameters and return an empty object literal. That's enough to get us to green. 

OK, what should we test next. Well, this controller needs to react to a `NewCardView` firing an `create-card` event by adding a card to a `CardWall`. That's quite a lot of functionality to bite off in one test but I don't really see a way to break it down, so let's just give it a go and see if we can express all of that in a reasonably small step:

``` coffeescript main_controller_spec.coffee
describe 'main controller', ->

  it 'reacts to a create-card event by creating a new card in the card wall', ->
    fakeNewCardView = _.extend({},Backbone.Events)
    fakeCardWall = _.extend({
      addCard: sinon.spy()
    })

    createMainController( newCardView:fakeNewCardView, cardWall: fakeCardWall )

    fakeNewCardView.trigger('create-card')
    expect(fakeCardWall.addCard).toHaveBeenCalled()
```

There's a lot going on here. We are creating fake instances of `NewCardView` and `CardWall`, and passing them into our controller's constructor function. Then we simulate a `create-card` event by explicitly triggering it in our test. Finally we check that our controller reacted to that `create-card` event by calling the `addCard` on the `CardWall` instance it was given during construction.

We created our fake instance of `NewCardView` by just taking the base `Backbone.Events` module and mixing it into an empty object.That module is the same module which is mixed into pretty much every Backbone-derived object (Model,View,Collection,Router, even the Backbone object itself!). By mixing the Events module into our empty object we now have methods like `on` and `trigger` implemented in our fake `NewCardView`. That's all we need our fake instance to do in this case.

So let's get this to pass:

``` coffeescript main_controller.coffee
createMainController = ({newCardView,cardWall})->
  newCardView.on 'create-card', ->
    cardWall.addCard()
  {}
```

Reasonably straight-forward. When the controller is constructed it now immediately registers a handler for any `create-card` events from the `NewCardView` instance - note that the controller is now being provided the `NewCardView` instance (and a `CardWall` instance) via the constructor function. The handler for that `create-card` event simply calls `addCard` on the `CardWall` instance.

That gets our previous test to green, but unfortunately it breaks our initial simple test. That test wasn't passing any arguments to the controller's constructor function. That means that `newCardView` is undefined, and calling `newCardView.on` fails. We could solve this by modifying that initial test to pass in some kind of fake `newCardView`. However, looking at that test it is providing no real value now. It was there to get us started TDDing our controller, and now that we're started we don't really need the test around. It's very unlikely to catch any regressions or provide any other value in the future. 

So we'll just delete that first test, which will bring out full test suite back to green again.

So we have a controller which reacts to `create-card` events by asking the `CardWall` to add a card, but it's not passing any information about the card from the `NewCardView` to the `CardWall`. Specifically, it's not passing the text which the user entered into the new card view. To drive out that functionality we can add a new test which describes the additional behaviour. However in this case that test would just be an expanded version of the existing test, so instead we'll just take our existing test and flesh it out more:

``` coffeescript main_controller_spec.coffee
describe 'main controller', ->

  it 'reacts to a create-card event by creating a new card in the card wall', ->
    fakeNewCardView = _.extend( {getText: -> 'text from new card'}, Backbone.Events )
    fakeCardWall = _.extend({
      addCard: sinon.spy()
    })

    createMainController( newCardView:fakeNewCardView, cardWall: fakeCardWall )

    fakeNewCardView.trigger('create-card',fakeNewCardView)
    expect(fakeCardWall.addCard).toHaveBeenCalledWith(text:'text from new card')
```

We've expanded our `fakeNewCardView` to include a stub implementation of the `getText` method. This method would be present on a `NewCardView` instance. We've also extended the event triggering in the test to also include the sender of the event. This what the full implemnentation of `NewCardView` that we implemented in the previous post does. We'll see in a second why that's needed. Finally we modify our verification step. Now instead of just checking that `addCard` was called it checks that it is called with a text parameter equal to the card text returned by the `NewCardView` instance's `getText` method.

We run this test and of course it fails, but it's very simple to get it passing:


``` coffeescript main_controller.coffee
createMainController = ({newCardView,cardWall})->
  newCardView.on 'create-card', (sender)->
    cardWall.addCard( text: sender.getText() )
  {}
```

The only thing we've changed here is to take the sender argument passed with the `create-card` event, grab the text from that sender and then include it when calling `cardWall.addCard`. Tests are green once more. Looking at this implementation you can see why we had to add the extra parameter in the explicit `fakeNewCardView.trigger('create-card',fakeNewCardView)` call in our test code. If we didn't pass the `fakeNewCardView` with the event then sender would be undefined in our controller code, which would cause the test to fail. It's unfortunately that this level of implementation detail leaked into our test writing, but that implementation detail is part of the `NewCardView` public API, so this isn't too big a concern.

## Our Controller is complete

And at this point we're done. We have a Controller which mediates between our Views and the rest of our app, creating new cards when a view tells it that the user wants a new card. 

## That's our Controller?!

Our controller ended up being 3 lines of code. Was that worth it? Why didn't we just throw that logic into `NewCardView`? 

Well, if we had done that then `NewCardView` would now have to know which `CardWall` it was associated with (so that it could call `addCard` on the right object. That means `NewCardView` would now be coupled directly to the `CardWall`. That means you either wire up each `NewCardView` with a `CardWall` - probably via constructor params or by setting fields - or worse you need `CardWall` to become a singleton. Both of these are design compromises. It's better to keep the different parts of your system decoupled if you can. 

Also note that if `NewCardView` knows about a `CardWall` then you are likely to start to have circular dependencies - Collections or Models  know about Views, which in turn know about other Collections or Models. Your design becomes quite hard to reason about - you don't really know what objects are involved in a particular interaction. More coupling also makes things harder to test. If a NewCardView is directly calling a `CardWall` whenever card creation is requested then you need to supply fake versions of `CardWall` in a lot of tests. That's one more piece of complexity in your tests which you have to read, understand and maintain.


