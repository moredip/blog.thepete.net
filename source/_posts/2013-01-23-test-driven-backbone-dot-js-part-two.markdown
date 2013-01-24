---
layout: post
title: "Test-driven Backbone.js - Part Two"
date: 2013-01-23 18:23
comments: true
categories: 
---

In the previous installment of this series we looked at the basics of test-driving the development of a Backbone.js app by TDDing some simple functionality for Backbone Models.

In this installment we're going to get a bit more advanced, looking at how we can test-drive Backbone Views. Because Views integrate with the DOM they can be a little more fiddly to test, but TDDing your views is still a very achievable goal.

## Jasmine-jQuery

Testing backbone Views is a lot about testing how javascript interacts with the DOM via jQuery. A helpful tool for this is a little extension to Jasmine called [Jasmine-jQuery](https://github.com/velesin/jasmine-jquery). Jasmine-jQuery adds a set of custom matchers to Jasmine which are focused on asserting on various properties of a $-wrapped DOM element. For example you can assert that a DOM element contains specific text, matches a specific selector, is visible (or hidden), etc. The project's [github README](https://github.com/velesin/jasmine-jquery#readme) describes all the matchers added by the plugin in detail.

## HTML Fixtures - a crutch 

Jasmine-jquery also provides a feature called *fixtures*. The idea here is that you describe any specific HTML content that you need to be available in the browser DOM during a test. Jasmine-jquery will ensure that that content is in the browser DOM before your test runs, and will take care of cleaning the content out after the test completes. This is a useful feature if you are testing JavaScript code which acts on content across the entire document using a $ selector. However in the context of a Backbone doing something like that is a bad practice. A Backbone View should never be accessing parts of the DOM outside of its own `el` property. JQuery's $ is essentially one huge global variable, and JavaScript which uses $ to access arbitrary parts of the DOM is hard to understand, hard to maintain, and hard to test.

So, although the fixtures functionality is useful I strongly advice explicitly avoiding using it - in the context of a Backbone application it is a crutch which we should never need.

## Our first View

Let's start off by building a CardView, which we'll use to render an instance of a Card model. As we did before, it's good to start off with a really simple test that drives out the simplest thing:

```coffeescript card_view_spec.coffee
describe CardView, ->
  it 'renders a div.card',->
    view = new CardView()
    expect( view.render().$el ).toBe('div.card')
```

This test should be pretty self-explanatory. We're saying that we expect a card view to render itself as a div of class 'card'. 

Of course it will fail initially because we haven't defined a CardView. Let's define a CardView, and while we're at it we might as well add the necessary configuration to get the test passing:

```coffeescript card_view.coffee
CardView = Backbone.View.extend
  tagName: 'div'
  className: 'card'
```

Now let's move on to our next test for this view. It's rendering as a div with the appropriate class, but what content is inside that div? If we're rendering a Card model then we probably want the text on that card to be rendered in our CardView:

```coffeescript card_view_spec.coffee
describe CardView, ->
  it 'renders a div.card',->
    view = new CardView()
    expect( view.render().$el ).toBe('div.card')

  it 'renders the card text', ->
    model = new Card(text:'I <3 HTML!')
    view = new CardView( new Card(text:'I <3 HTML!') )
    expect( view.render().$el.find('p') ).toHaveText("I <3 HTML!")
```

In our new test we create an instance of a Card model with some specific text. We then create a CardView instance for that model. Finally we render that CardView instance and verify that its `$el` contains a `<p>` tag with the Card model's text. Note we also include some funky characters in our Card text to make sure we're doing entity encoding correctly.

This is quite a complex test, but it's pretty easy to get passing:

```coffeescript card_view.coffee
CardView = Backbone.View.extend
  tagName: 'div'
  className: 'card'

  render: ->
    @$el.html( "<p>#{@model.escape('text')}</p>" )
    @
```

We've added a render method to our view. This method replaces whatever html is currently in the view's `$el` with a `<p>` tag containing the html-escaped contents of the model's `text` attribute. 

We're still following Simplest Possible Thing here. I was tempted to start using a templating system, but for the sake of this one `<p>` tag it seemed unnecessary. So we're using good old-fashioned string interpolation until we reach a point where a template makes more sense.
