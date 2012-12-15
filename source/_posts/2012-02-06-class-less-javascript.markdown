---
layout: post
title: "Class-less javascript"
date: 2012-02-06T23:26:00-08:00
comments: false
---

It seems that [every](http://blog.thepete.net/blog/2012/02/06/class-less-javascript/) <a href="http://www.prototypejs.org/learn/class-inheritance">javascript</a> <a href="http://www.sencha.com/blog/countdown-to-ext-js-4-dynamic-loading-and-new-class-system">framework</a> <a href="http://emberjs.com/#object_model">of</a> <a href="http://sproutcore.com/docs/#doc=SC.Object&amp;method=.extend">a</a> <a href="http://developer.yahoo.com/yui/examples/yahoo/yahoo_extend.html">certain</a> <a href="http://dojotoolkit.org/documentation/tutorials/1.6/declare/">size</a> is compelled to implement some kind of pseudo-classical type system. I am now fairly convinced that there is no good reason for doing so. I'd like to describe an alternative approach to dealing with types in JavaScript. 

This approach comes from a recent project where my team was building a pure-JavaScript single-page web application. This wasn't a huge codebase, but due to the single-page nature of the app it did have a reasonable amount of non-presentation logic which was implemented client-side in JavaScript. We needed a type system but we knew we didn't want to try and force a classical-OO system onto JavaScript. The patterns we evolved gave us just enough structure while still allowing us to take advantage of the highly flexible and dynamic nature of JavaScript.

In this post I'll be summarizing the major parts of the lightweight, class-less type system we created. Before that I'll start with a brief tour of JavaScript, covering language concepts which are relevant to our approach. If there is sufficient interest in this topic I may write this up in more detail here over a series of posts.

##A quick tour of JavaScript

###Prototypical, not Classical
JavaScript is not a classical Object-Oriented language. Over the years many have tried to force it into that mold, but it just doesn't fit. In JavaScript typing is achieved through the use of <em>prototypes</em>, not classes.

In languages like Ruby or Java you have Classes and Objects. An Object is always the instance of a specific Class. You generally define an object's behaviour by specifying that behaviour in the object's class (for the sake of clarity I'm glossing over things like ruby's eigenclass). On the other hand in JavaScript an object's type is not determined by its <em>class</em>, but is instead based on the object's <em>prototype</em>. Unlike classes, a prototype has no special qualities. Any object can act as the prototype for another object. A prototype is not distinct from other objects, nor does it have a special type.

In a classical OO language an object derives behaviour and state-shape (i.e. member variables) from its class, and also from superclasses of its class. In JavaScript, an object derives behaviour from its prototype and also from its prototype's prototype, and so on up the prototype chain.

###Objects are just a bag of key-value pairs
JavaScript objects are in essence just a dictionary of key-value pairs called properties (plus a prototype as described above). Public object state is added directly to the object as a property, and object <em>methods</em> are simply a function which has been added directly to the object (or its prototypes) as a property.

###Closures as an alternate source of per-instance state
Storing state directly in an object via its properties would mean that that state is publicly accessible in a similar fashion to a public instance variable in an OO language. This has the same drawbacks as in other languages (uncontrolled access, unclear public interfaces, etc.). To avoid this pitfall a common idiom used in JavaScript to control access to state is to instead store that state outside of the object itself, but rather as local variables of the function which created that object. Due to the scoping rules of JavaScript those local variables are <em>closed over</em> by the object, and are thus available for access and modification.

<a id="closure-code-sample"></a>
``` js closure-encapsulates-object-state.js
function createDuck( name ){
  var duck = {
    fullName: function(){ name + " duck"; }
  };
  return duck;
};
```

Note that the duck instance we create is <em>not</em> storing its name anywhere inside the object. Instead the <em>name</em> argument passed to the createDuck function has been closed over, and is accessible to that duck instance. Also note that the value of <em>name</em> is therefore private. In fact it is private in a very strong sense. It is <strong>impossible</strong> for any client of the duck instance to see or modify the value of that name variable. No tricks of reflection or runtime object manipulation can get around this. Interesting sandboxing systems such as <a href="http://code.google.com/p/google-caja/">Caja</a> have been built up around this property of JavaScript.

##A lightweight type system for JavaScript

###Constructor functions, not classes
In a typical OO system you would define the types in your system using classes such as Duck, Pond, Food, etc. The orthodox approach in JavaScript would be to define types using prototypes. In our approach we do neither. We have no classes or prototypes, just constructor functions. Each type in the system has one or more constructor functions which create instance of that type. So we would have createDuck(&hellip;), createPond(&hellip;), createFood(&hellip;).

The <a href="#closure-code-sample">closure code sample above</a> shows the general form these constructor functions take. The equivalent of methods and member variables are defined inside the constructor function and at the tail end of the function an object with references to the methods is created and returned.

###State via closure
As mentioned earlier, storing state directly in object properties is analogous to having public instance variables. There are very few cases where this is a good idea. Instead our objects maintain state via closed-over local variables declared in the object's constructor functions. In this way object state is private and encapsulated but still available for manipulation by the object's functions, because they are declared in the same constructor function. Access to state is exposed in the public interface of a type instance via these functions which are added to the returned object, becoming 'methods' on that instance.

<a id="mixin"></a>
###Mixins for shared public behaviour
In JavaScript public 'methods' are just functions added to an object as a property. This means you can easily mix in new public behaviour by just merging the contents of the a mixin object with the instance itself. For example:

``` js extending-with-mixins.js
var shouter = {
  shout: function(){ return this.speak().toUpperCase(); }
};
 
function createShoutyDuck( name ){
  return _.extend( createDuck(name), shouter );
};
```

Here we have a <em>shouter</em> mixin and a <em>createShoutyDuck</em> constructor function which uses that mixin to construct a new type of duck which can shout. The constructor achieves this by using the methods defined in <em>shouter</em> to extend the duck type that is defined by the <em>createDuck</em> constructor function. We often use this pattern as an alternative to implementation inheritance. Instead of a base class which provided standard behaviour and subclasses which layer on additional behaviour we instead would have a base mixin which provides standard behaviour and constructor functions which define types by mixing together that standard base behaviour with additional type-specific behaviour. It's also interesting to note that as well as using mixins to extend a type via a constructor function it is also possible to extend specific instances of a type with mixed in functionality on an ad-hoc basis. This allows interesting dynamic patterns such as mixing in 'admin' methods to a specific instance of a User type once they have been authorized as an admin via a service call.

###Namespacing 
We follow the standard practice in large JavaScript codebases of namespacing using the <a href="http://www.adequatelygood.com/2010/3/JavaScript-Module-Pattern-In-Depth">module pattern</a>. Coupled with our other practices, this means that a module will generally only expose a small number of constructor functions to other parts of the system. Inside a namespace we may have quite a few types (and thus constructor functions), but across module boundaries only a few types are shared, and thus only a few constructor functions exposed. This is a natural outcome of following the time-honored practice of organizing modules with low coupling and high cohesion in mind. Global variables are avoided at all costs, and pseudo-global variables (i.e. raw variables tacked on to a top-level namespace) are considered a design smell.

###Dependencies
Dependencies are wired together in an initial boot function. Because this function's role is to connect large modules together it has a side-effect of documenting in a relatively declarative, high-level way how the various parts of the system depend on each other.

Dependencies are generally hooked in by providing constructor functions as parameters to other constructor functions. As well as directly passing constructor functions, it's also quite common that <a href="http://ejohn.org/blog/partial-functions-in-javascript/">partially-specified</a> constructor functions are used to encapsulate lower-level or cross-functional dependencies. Here's another contrived example:

``` js currying-and-constructor-functions.js
function createLogger( category ){
  // some implementation here
};
 
function createDuck( name, logger ){
    return {
      speak: function(){
        logger( name + ' was asked to speak' );
        return 'quack';
      }
    };
};
 
(function boot(){
  var duckLogger = createLogger('duck');
 
  function curriedCreateDuck(name){
    return createDuck( name, duckLogger );
  }
  globals.createDuck = curriedCreateDuck;
}());
```

This example shows two distinct applications of currying. First, we have exposed a curried createDuck function to the outside world, with the logger dependency hidden. We also used a curried createLogger function called duckLogger to pass to the createDuck function. Again this was to remove cross-functional implementation details (about logging in this case) which the createDuck constructor should not be aware of or care about.

There is a strong similarity between our use of partially applied functions and the parameterized Factory classes you see quite often in statically typed OO code (particularly Java).

A notable advantage of this dependency injection approach is that modules can easily be tested in isolation by injecting test doubles in place of real dependencies.

##Outcomes
###Composition over Inheritance
A slightly unfortunate side-effect of capturing our instance state in closures is that it is hard to expose that state to mixins and sub-classes, as the state is only available via lexical scoping and is not available via the <em>this</em> keyword. Another way of putting this is that there is no equivalent of the 'protected' scope found in a language like C++ or Java. This leads to a favoring of composition over inheritance/mixin when it comes to sharing common behaviour between types. Instead of mixing in behaviour that requires access to private state we would wrap that behaviour in a helper object. That helper object would be available to types which need it via their constructor function. Instances of those types would then call out to that helper object as needed, passing in the private state needed by the helper to provide its functionality. Sort of a 'tell-don't-ask' approach to using shared behaviour.

###No prototypes, no <em>new</em>, less <em>this</em>
By following this approach to creating types we've found no need for the prototypical type system built into JavaScript. Our code does not use the <em>new</em> operator at all, except when interacting with libraries or frameworks which require the use of <em>new</em> to instantiate objects.

The lack of <em>new</em> also means usage of the <em>this</em> keyword becomes less frequent. References from a method's implementation to member variables or to other methods in a type are mostly achieved via lexical scoping. <em>this</em> is only really needed when writing mixins which achieve their work by calling hook methods implemented in the instances they are mixed into - see the <a href="#mixin">shouty duck sample above</a> for an example of that.

##Conclusion
I have been honestly rather surprised at how well this class-less approach has worked. I would certainly use it (and refine it) in future JavaScript projects.

I'd love to hear feedback on what I've outlined here. If there is interest I may write some follow-up posts diving into more detail on some of the aspects I've touched on here.
