---
layout: post
title: "Test-driven Backbone.js - Part Two"
date: 2013-01-23 18:23
comments: true
categories: 
---

In the [previous installment](/blog/2013/01/23/test-driven-backbone-dot-js-part-one/) of this series we looked at the basics of test-driving the development of a Backbone.js app by TDDing some simple functionality for Backbone Models.

In this installment we're going to get a bit more advanced, looking at how we can test-drive Backbone Views. Because views integrate with the DOM they can be a little more fiddly to test, but TDDing your views is still a very achievable goal.

## Jasmine-jQuery

Testing backbone views is in large part about testing how JavaScript interacts with the DOM via jQuery. A helpful tool for this is a little extension to Jasmine called [Jasmine-jQuery](https://github.com/velesin/jasmine-jquery). Jasmine-jQuery adds a set of custom matchers to Jasmine which make it easier to assert on various properties of a $-wrapped DOM element. For example you can assert that a DOM element contains specific text, matches a specific selector, is visible (or hidden), etc. The project's [github README](https://github.com/velesin/jasmine-jquery#readme) describes all the matchers added by the plugin in detail.

## HTML test fixtures - to be avoided if possible

Jasmine-jQuery also provides a feature called *[fixtures](https://github.com/velesin/jasmine-jquery#html-fixtures)*. The idea here is that you describe any specific HTML content that you need to be available in the browser DOM during a test. Jasmine-jQuery will ensure that that content is in the browser DOM before your test runs, and will take care of cleaning the content out after the test completes. This is a useful feature if you are testing JavaScript code which acts on content across the entire document using a $ selector. In that situation you sometimes have to pre-load the DOM with the HTML which that $ selector is expecting in order to test how the JavaScript under test behaves.

However in the context of a Backbone we shouldn't need to lean on fixtures too often. In fact if we need to use fixtures often in our Backbone View tests then we should be concerned. This is because in most cases a Backbone view should not be accessing parts of the DOM outside of its own `el` property and thus should not need fixtures during testing. The DOM is essentially one big chunk of mutable shared state (or, put another way, one big global variable) and we should avoid relying upon that shared state in our design unless absolutely necessary. 

Mutable shared state is a tricky thing to deal with in code. You can never be sure what code is going the change the state, and when. You have to think about how your entire application works whenever you change how you interact with that state. A Backbone view which restricts itself to just modifying its own `el` on the other hand is easy to reason about - all code that modifies that state is localized within that view's implementation, and it is usually easy to hold in your head all at once. This very powerful advantage goes out of the window when we start accessing state that's not owned by the view. So, we should strive to avoid access to the wider DOM whenever possible by restricting our view to only touching its own `el` property. If we do this then we have no need for fixtures. This means that if we are relying on fixtures a lot then that should be considered a test [smell](http://www.codinghorror.com/blog/2006/05/code-smells.html) which is telling us that we are failing in our goal of keeping as much DOM-manipulation code as possible localized to within a single view.

The one place where we must relax this guidance a little is when we have what I call *Singleton Views*. These are top-level Backbone views in our Single Page App which bind themselves to pre-existing 'shell' sections of the DOM which came down into the browser when the app was first loaded. These views are generally the highest level visual elements in the application, and as such there tend to be no more than 3 or 4 Singleton Views in a given <abbr title="Single Page App">SPA</abbr>. For example a Gmail-type app may have Singleton Views for a navigation bar, a tool bar, the left-hand folder view and the main right-hand email container. 

In order to test these Singleton Views properly we need to test them in the context of the initial DOM structure which they will bind themselves to, since this is the context they will always be within in when the full app is running. HTML fixtures allow us to write tests for these Singleton Views in the context of their DOM structure but in an independent way, without affecting other tests. We'll see an example of TDDing a Singleton View when we create the New Card view later on. 

## Our first View

Let's start off by building a `CardView`, which our app will use to render an instance of a `Card` model. As we did before we'll start off with a test, before we even have a `CardView` defined at all. Also like before it's good to start off with a simple test that drives out an basic initial implementation of what we're building.

```coffeescript card_view_spec.coffee
describe CardView, ->
  it 'renders a div.card',->
    view = new CardView()
    expect( view.render().$el ).toBe('div.card')
```

This test should be pretty self-explanatory. We're saying that we expect a card view to render itself as a div of class 'card'. Note that we take advantage of Jasmine-jQuery's `toBe` matcher here, which says 'the element in question should match this css selector'.

Of course this test will fail initially because we haven't even defined a `CardView`. Let's get the test passing by defining a `CardView` along with the necessary configuration specifying what class and type of tag it renders as:

```coffeescript card_view.coffee
CardView = Backbone.View.extend
  tagName: 'div'
  className: 'card'
```

With that we're back to green. Now let's move on to our next test for this view. It's rendering as a div with the appropriate class, but what content is inside that div? If we're rendering a `Card` model then we probably want the `text` attribute within that card model to be rendered in our `CardView`:

```coffeescript card_view_spec.coffee
describe CardView, ->
  it 'renders a div.card',->
    view = new CardView()
    expect( view.render().$el ).toBe('div.card')

  it 'renders the card text', ->
    model = new Card(text:'I <3 HTML!')
    view = new CardView( model: model )
    expect( view.render().$el.find('p') ).toHaveText("I <3 HTML!")
```

In our new test we create an instance of a `Card` model with some specific text. We then create a `CardView` instance for that model. Finally we render that `CardView` instance and verify that its `$el` contains a `<p>` tag which itself contains the `Card` model's text. Note we also include some funky characters in our card text to get some confidence that we're escaping our HTML correctly.

That's quite a complex test, but it's pretty easy to get passing:

```coffeescript card_view.coffee
CardView = Backbone.View.extend
  tagName: 'div'
  className: 'card'

  render: ->
    @$el.html( "<p>#{@model.escape('text')}</p>" )
    @
```

We've added a `render` method to our view. This method replaces whatever html is currently in the view's `$el` with a `<p>` tag containing the html-escaped contents of the model's `text` attribute. 

We're still following Simplest Possible Thing here. we could start using some sort of client-side templating to render our view, but for the sake of this one `<p>` tag it seems unnecessary. So we're using good old-fashioned string interpolation until we reach a point where a template makes more sense.

It turns out that this new `render` method gets our second test passing but also breaks our first test. Our first test doesn't pass a model to the `CardView` constructor, which means that the subsequent call to `@model.escape('text')` fails. We'll quickly fix up our tests:

```coffeescript card_view_spec.coffee
describe CardView, ->
  createView = ( model = new Card() ) ->
    new CardView(model:model)

  it 'renders a div.card',->
    view = createView()
    expect( view.render().$el ).toBe('div.card')

  it 'renders the card text', ->
    model = new Card(text:'I <3 HTML!')
    view = createView( model )
    expect( view.render().$el.find('p') ).toHaveText("I <3 HTML!")
```

That gets us back to green. We've added a little `createView` helper function. We can explicitly pass it a model to use when it constructs a view, but if we don't care we can just have the helper function create some generic model to supply the view with.


## a View for adding new cards

A card wall isn't much use if you can't add new cards to the wall. Let's start addressing that by creating a `NewCardView`. This view which will represent the user interface used to supply text for a new card and then add it to the card wall.

This `NewCardView` will be a *Singleton View* - rather than creating its own `el` DOM element at construction time it will instead bind `el` to a DOM element which already exists on the page when it loads. First off let's take a first stab at what that pre-existing HTML will look like by creating a shell index.html file:

``` html index.html
<html>
  <body>
    <section id='new-card'>
      <textarea placeholder='Make a new card here'></textarea>
      <button>add card</button>
    </section>
  </body>
</html>
```

Pretty simple. a `<textarea>` to enter the card's text into a `<button>` to add a card with that text to the wall.  Now let's drive out the basics of our `NewCardView`:

``` coffeescript new_card_view_spec.coffee
describe 'NewCardView', ->

  it 'binds $el to the right DOM element', ->
    loadFixtures 'index.html'
    view = new NewCardView()
    expect( view.$el ).toBe( 'section#new-card' )

```

Here we use Jasmine-jQuery's `loadFixtures` helper to insert the contents of our index.html file into the DOM, but only for the duration of the test. Note that we're inserting the regular index.html into our DOM during testing, not a test-specific fixture. Doing this gives us more confidence that we're testing the Singleton View in the same context as when it's running in our real app. Next we create a `NewCardView` instance and verify that its `$el` is bound to the right `<section>` within that initial static HTML coming from `index.html`. Let's get that first test passing:

``` coffeescript new_card_view.coffee
NewCardView = Backbone.View.extend
  el: "section#new-card"
```

As we can see, Backbone makes it very easy to create a Singleton View. We simple specify a css selector as the `el` field. When the view is constructed that CSS selector string is used to select a DOM element within the page which the view instance's `el` will then refer to.

## Test-driven DOM event handling

Now that we have driven out the basic view, let's write a test for some event firing behaviour. We want our view to trigger an event whenever the user clicks the 'add card' button. As we did before, we'll use Sinon spy functions in our test to describe the behavior we expect:


``` coffeescript new_card_view_spec.coffee
describe 'NewCardView', ->

  it 'binds $el to the right DOM element', ->
    loadFixtures 'index.html'
    view = new NewCardView()
    expect( view.$el ).toBe( 'section#new-card' )

  it 'triggers a create-card event when the add card button is clicked', ->
    loadFixtures 'index.html'
    view = new NewCardView()

    eventSpy = sinon.spy()
    view.on( 'create-card', eventSpy )

    $('section#new-card button').click()

    expect( eventSpy ).toHaveBeenCalled()
```

In this new test we register a spy on a `NewCardView` instance's `create-card` event, so that whenever that instance triggers an event of that type it will be recorded by the spy. Then we use jQuery to simulate a click on the 'add card' button. Finally we verify that the `create-card` event was triggered by checking whether the spy we registered for that event has been called. 

This test will fail of course, since we haven't implemented any custom `create-card` event in `NewCardView`. Let's do that now and get the test passing:

``` coffeescript new_card_view.coffee
NewCardView = Backbone.View.extend
  el: "section#new-card"

  events:
    "click button": "onClickButton"

  onClickButton: ->
    @trigger( 'create-card' )
```

Here we use the `events` field to declaratively tell our Backbone View that whenever a `<button>` within the view's `el` receives a `click` event it should call the view's `onClickButton` method. In addition we implement that `onClickButton` method to trigger a `create-card` event on the view itself. 

This is a very common pattern in Backbone views. They react to low-level DOM events within their `el` and re-publish a higher-level application-specific event. Essentially the Backbone view is acting as a translation layer between the messy low-level details like DOM elements and click events and the more abstract higher-level application concepts like creating a card.

Now that our tests are green again we can do a little refactor of our test code, DRYing it up a little:

``` coffeescript new_card_view_spec.coffee
describe 'NewCardView', ->

  view = null
  beforeEach ->
    loadFixtures "index.html"
    view = new NewCardView

  it 'binds $el to the right DOM element', ->
    expect( view.$el ).toBe( 'section#new-card' )

  it 'triggers a create-card event when the add card button is clicked', ->
    eventSpy = sinon.spy()
    view.on( 'create-card', eventSpy )

    $('section#new-card button').click()

    expect( eventSpy ).toHaveBeenCalled()
```

Nothing exciting here, we just extracted out the common test setup stuff into a `beforeEach`.

Now, maybe we can improve `NewCardView`'s API a little here. Something that's receiving one of these `create-card` events will probably want to react to that event by finding out more details about the new card which the user is asking to create. Let's elaborate on that second test and say that we want the `create-card` event to pass along the view which triggered the event.

``` coffeescript new_card_view_spec.coffee
describe 'NewCardView', ->

  view = null
  beforeEach ->
    loadFixtures "index.html"
    view = new NewCardView

  it 'binds $el to the right DOM element', ->
    expect( view.$el ).toBe( 'section#new-card' )

  it 'triggers a create-card event when the add card button is clicked', ->
    eventSpy = sinon.spy()
    view.on( 'create-card', eventSpy )

    $('section#new-card button').click()

    expect( eventSpy ).toHaveBeenCalledWith(view)
```

All we've done here is expanded our expectation at the bottom to say that we expect our event spy to have been passed the view which triggered the event as an argument. That test will now fail, but it's trivial to get it passing:


``` coffeescript new_card_view.coffee
NewCardView = Backbone.View.extend
  el: "section#new-card"

  events:
    "click button": "onClickButton"

  onClickButton: ->
    @trigger( 'create-card', @)
```

An extra 3 characters and we've added an argument to the `trigger` call which passes a reference to the view itself to anyone listening for that `create-card` event.

So if someone has received this event and has a reference to the view they're probably going to want to get access to whatever text the user has entered into the text area. Let's drive that API out:


``` coffeescript new_card_view_spec.coffee
describe 'NewCardView', ->

  view = null
  beforeEach ->
    loadFixtures "index.html"
    view = new NewCardView

  # ... other tests ....

  it 'exposes the text area text', ->
    $('section#new-card textarea').val('I AM A NEW CARD')
    expect( view.getText() ).toBe( 'I AM A NEW CARD' )

```

We're using jQuery to simulate a user entering text into the text area, and then verifying that we can fetch that text using a `getText` method on the view. Of course this test will fail because the view has no `getText` method. Let's address that:


``` coffeescript new_card_view.coffee
NewCardView = Backbone.View.extend
  el: "section#new-card"

  events:
    "click button": "onClickButton"

  onClickButton: ->
    @trigger( 'create-card', @)

  getText: ->
    @$('textarea').val()
```

We're using the view's `$(...)` helper method to do a scoped lookup of the `<textarea>` element inside our view's `el`. It is a shorthand way of saying `@$el.find('textarea')`. Then we just grab the value of that `<textarea>` and return it. Tests are green once more.

## Wrap up

Our new card view now provides all the functionality we need, so we'll wrap this up. 

In this installment we've seen how Jasmine-jQuery can help assert what HTML is being rendered by our Backbone Views, and how its Fixtures functionality can help set up pre-requisite chunks of HTML content for the duration of a test. That said, we've also learned that if we require fixtures to test our views then this could indicate a poor design. We've observed that Backbone views act as a translation layer between the core of the application and the DOM. Finally, we've seen how to use jQuery to simulate user interactions and how sinon spy's can be used to check that events are being triggered correctly.

In the [next installment](/blog/2013/02/24/test-driven-backbone-dot-js-part-three/) of this series I cover where Controllers fit into a Backbone app and show how we can TDD the implementation of them.
