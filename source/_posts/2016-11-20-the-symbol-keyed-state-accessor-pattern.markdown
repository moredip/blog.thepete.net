---
layout: post
title: "The Symbol-Keyed State Accessor pattern"
date: 2016-11-20 14:33
comments: true
categories: 
---

In this post I'll show three different techniques for encapsulating internal state in JavaScript, concluding with my prefered approach, a pattern I'm calling "Symbol-keyed State Accessor".

I was in a discussion about how to implement the Value Object pattern in JavaScript recently. Most of the examples folks were proposing involved a prototypical approach to OOO, using either `class` or `prototype` to create a Value Object type, and managing the object's internal state via `this`. Here's how one might build the basics of a `Money` Value Object in that style:

``` javascript class-based-money.js
module.exports = class Money {
  constructor(amount,currency){
    this._amount = amount;
    this._currency = currency;
  }

  currency(){
    return this._currency;
  }

  amount(){
    return this._amount;
  }

  equals(other){
    return this._amount === other._amount
      && this._currency === other._currency;
  }
}
```
Of note is that we're implementing a custom value equality method. Equality-by-value is an important aspect of the Value Object pattern.

As I've [previously noted](/blog/2012/02/06/class-less-javascript/), I'm not a fan of traditional JavaScript OOP. I started sketching out what a closure-based approach might look like:

``` javascript closure-based-money.js
module.exports = function Money(_amount,_currency){
  function currency(){
    return _currency;
  }

  function amount(){
    return _amount;
  }

  function equals(other){
    other = other._getState();
    return _amount === other._amount
      && _currency === other._currency;
  }

  function getState(){
    return {_amount,_currency};
  }

  return {
    currency,
    amount,
    equals,
    _getState: getState
  };
}
```

This is mostly a vanilla example of how to build a type in JavaScript without using prototypical inheritance. Again, something [I've discussed in depth previously](http://radar.oreilly.com/2014/03/javascript-without-the-this.html). However there is one wrinkle here. Usually I would want to avoid exposing a Money instance's internal state at all - one of the big advantages of the closure-based approach is the encapsulation it provides by preventing direct access to internal state. However in order to implement the `equals(...)` method we need some way to compare our state to another Money's state, which means we have to expose that state somehow. In this example I enabled this by adding a `_getState()` method. The leading underscore is a common (if ugly) convention used to indicate that this is not part of the type's public API. We saw a similar convention in our first class-based example too.

Having to use a leading underscore is exactly the sort of thing that I dislike about `this`-based JavaScript code. Unfortunately it didn't seem to be avoidable here, even with a closure-based approach that doesn't use `this` at all. As I was contemplating this sad outcome I turned to considering how other languages handle this. Most object-oriented languages provide the ability to explicitly mark parts of an API as private or internal; only accessible to an instance of the same class. Javascript is missing this feature, but with a `this`-less approach we can mostly fake it using lexical scoping to prevent access outside the scope of the closure which defines a type. Unfortunately this protection is too strong in this case - it prevents other instances of the same type from accessing a private API. That led to us having to resort to naming things with leading underscores, hoping to persuade consumers of this type to not bypass our public API. In my experience this hope turns out to be overly optimistic in the face of engineers with a tight deadline and a somewhat unrealistic belief that they'll "come back and fix this later".

## Symbol-keyed properties

What I needed was some way to expose state to other instances of the same type but to nothing else. Eventually I remembered that JavaScript gained a new feature in ES6 that was designed for just this scenario - [the Symbol type](https://hacks.mozilla.org/2015/06/es6-in-depth-symbols/). 

When a property is added to an object using a Symbol as a key - a _symbol-keyed property_ - it doesn't show up in things like `for .. in` loops, or in calls to `Object.keys()` or `Object.getOwnPropertyNames()`. It's also (almost) impossible to access a symbol-keyed property if you don't have access to the Symbol itself. We can take advantage of this feature along with JavaScript's lexical scoping rules to create an encapsulated object property which is only accessible by code in the same lexical scope as the code that created the property. 

Here's how we leverage this to implement a better version of our Money type:

``` javascript money-with-symbol-keyed-encapsulation.js
const stateAccessor = Symbol(['Money#getState']);

function stateFrom(money){
  return money[stateAccessor]();
}

module.exports = function Money(_amount,_currency){
  function currency(){
    return _currency;
  }

  function amount(){
    return _amount;
  }

  function equals(other){
    other = stateFrom(other);
    return _amount === other._amount
      && _currency === other._currency;
  }

  function getState(){
    return {_amount,_currency};
  }

  return {
    currency,
    amount,
    equals,
    [stateAccessor]: getState
  };
}
```

Note that *within this file* anything can access a Money instance's state using the `stateFrom()` function, which in turn uses the `stateAccessor` symbol. We use `stateFrom()` in `equals(other)` to access the other Money instance's state. However outside of this file there is no way to access either `stateFrom` or `stateAccessor` (due to lexical scoping), and therefore no way to access a Money instance's internal state.

## Addendum
Technically in some cases you *can* access a symbol-keyed property without access to the original symbol, but it's pretty dirty:

``` javascript hackery.js
const someMoney = Money(5,'USD');
const privateProperties = Object.getOwnPropertySymbols(someMoney);
const stateAccessor = privateProperties[0]; // let's hope our stateAccessor is always the first property!
const privateState = someMoney[stateAccessor]();
```

In my opinion this is gross enough that anyone violating an object's privacy this way would be aware that they are really going against the grain of that object's API and should be responsible for the consequences.
