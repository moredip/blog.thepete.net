---
layout: post
title: "Javascript Promises"
date: 2011-07-02T06:37:00-07:00
comments: false
---

One of the interesting aspects of Javascript development is its asynchronous, event-driven nature. Any operation which will take a significant amount of time (e.g. a network request) is non-blocking. You don't call a function and block until the operation completes. Instead functions are non-blocking - they return before the operation is complete. To obtain the result of the operation you provide *callbacks* which are subsequently invoked once the operation completes, allowing you to move on to the next stage in your computation. This is a very powerful, efficient model that avoids the need for things like explicit threading and all the associated synchronization problems. However, it does make it a bit harder to implement a set of operations that need to happen one after another in sequential series. Instead of writing:

``` javascript
var response = makeNetworkRequest(),
processedData = processResponse(response);
writeToDB( processedData );
```

you end up writing:

``` javascript
makeNetworkRequest( function(response){
  var processedData = processResponse(response);
  writeToDB( processedData, function(){
    // OK, I'm done now, next action goes here.
  });
});
```

<p>This is the start of what is sometimes referred to as a <em>callback pyramid</em> - callbacks invoking subsequent operations passing in callbacks which are invoking subsequent operations, and on and on. This is particularly common in node.js code, because most server-side applications involve a fair amount of IO-bound operations (service calls, DB calls, file system calls) which are all implemented asynchronously in node. Because this is a common issue there have been a rash of libraries to help mitigate it. See for example <a href="http://www.infoq.com/articles/surviving-asynchronous-programming-in-javascript">&ldquo;How to Survive Asynchronous Programming in JavaScript&rdquo; on InfoQ</a>.</p>

<p>One approach to help cope with these issues in asynchronous systems is the Promise pattern. This has been floating around the comp-sci realm since the 70s, but has recently found popularity in the javascript community as it starts to build larger async systems. The basic idea is quite simple. When you call a function which performs some long-running operation instead of that function blocking and then eventually returning with the result of the operation it will instead return immediately, but rather than passing back the result of the operation (which isn&rsquo;t available yet) it passes back a <em>promise</em>. This promise is a sort of proxy, representing the <em>future</em> result of the operation. You would then register a callback on the promise, which will be executed by the promise once the operation does complete and the result is available. Here&rsquo;s the same example as I used before, implemented in a promise style:</p>

``` javascript
var networkRequestPromise = makeNetworkRequest();
networkRequestPromise.then( function(response){
  var processedData = processResponse(response),
  dbPromise = writeToDB(processedData);
  dbPromise.then( function(){
    // OK, I'm done now, next action goes here.
  });
});
```

I created local promise variable here to show explicitly what&rsquo;s happening. Usually you&rsquo;d inline those, giving you:

``` javascript
makeNetworkRequest().then( function(response){
  var processedData = processResponse(response); 
  writeToDB(processedData).then( function(){
    // OK, I'm done now, next action goes here.
  });
});
```

For a simple example like this there&rsquo;s really not much advantage over passing the callbacks as arguments as in the previous example. The advantages come once you need to compose asynchronous operations in complex ways. As an example, you can imagine a server-side app wanting to do something like: &ldquo;make this network request and read this value from the DB in parallel, then perform some computation, then write to the DB and write a log to disk in parallel, then write a network response&rdquo;. The beauty of a promise is that it is an encapsulated representation of an async operation in process which can be returned from functions, passed to functions, stored in a queue, etc. That&rsquo;s what allows the composition of async operations in a more abstract way, leading to a much more manageable codebase.
