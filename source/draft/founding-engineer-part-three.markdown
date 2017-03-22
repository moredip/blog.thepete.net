---
layout: post
title: "Advice for the Founding Engineer - Maxim #3"
date: 2017-03-16 05:11
comments: true
categories: 
---

As a founding engineer at a new startup you are tasked with getting an initial product out of the door ASAP while still supporting what comes after the MVP. Those two goals are somewhat in tension, and you are confronted on a daily basis with decisions that often involve finding the right balance between the two. I've condensed my opinions on how to succeed as a founding engineer into 3 core maxims which can help guide your decision making. In this series of posts I introduce each maxim along with discussion of some more concrete rules of thumb that emerge when you follow these maxims.

In previous posts in this series I introduced my first two maxims - "You'll Never Know Less Than You Know Right Now" and "Optimize For Iteration". In this post I'll cover my third and final maxim: "Boring Is Good". 

## Maxim 3: Boring is good
Your goal as a startup engineer is *not* to use cool tech (despite the fact that you might not have anyone telling you not to). Your goal is to deliver a product rapidly on top of a nimble technical foundation which will allow rapid iteration (see Maxim #2). Established technology is more likely to get you there. Buying technology will get you there quicker than building it. 


### Choose boring tech
(with due credit to [Dan McKinley](http://mcfunley.com/choose-boring-technology))

Keep in mind that cutting edge technology will be buggier, will have less community support, and a weaker ecosystem of supporting libraries and frameworks. How will you feel justifying why you ended up having to implement the first OAuth integration in the shiny new web framework you picked, or even worse fixing bugs in the existing OAuth integration that has only seen production usage in 4 other apps so far? 

Be aware that your cognitive biases make you lean towards shiny new things. For example [Availability heuristic bias](https://en.wikipedia.org/wiki/Availability_heuristic) may lead you to think that shiny new tech X solves all of the problems of established tech Y, when actually it's just that those shiny new tech X hasn't been around long enough to accumulate evidence of its problems shortcomings.

The place to consider using shiny technology is where it's needed as part of your product differentiation - if you're entire startup hypothesis is centered around using deep AI to disrupt the dog grooming industry then maybe Tensor Flow makes sense. However, keep in mind that even if you're doing deep technical innovation around your differentiator you still don't need to use shiny tech everywhere. You can still build your user signup flow as a boring old Rails app.

The other reason to use cutting-edge tech is if it will truly allow you to iterate faster. Perhaps you're convinced that building your mobile app in React Native will get you to market quicker, or allow you to deliver new releases quicker than a native Swift app. In that case, go for it. But again, try to keep your biases in check. Play devil's advocate for a moment and sketch out what a solution would look like in a more established technology and whether it would truly be more expensive.

### Buy what you can, build what you must.
The reason modern tech startups can do so much with so little comes down to the fact that what we used to have to build we can now buy. Instead of racking up servers and configuring networking gear we now click a few buttons in AWS (or even better run a declarative infrastructure-as-code tool like Terraform). When you're dealing with extremely limited resources it only makes sense to build something yourself if you really have to. This boils down to only building things if they are your product differentiator - and even then you are usually "building" by assembling open-source tools. 

If you're building something that isn't unique to your product, challenge yourself as to why. Why are you building user login when you could use Auth0 or Stormpath. Why are you hand-rolling your marketing pages when you could be using a Wordpress installation? Why are you standing up a kubernetes cluster when you could be deploying on Heroku? Why are you managing your own databases when you could be using a host DB-as-a-Service? Sometimes there are good reasons to build, but when we are really honest with ourselves sometimes we're building rather than buying because it's fun to play with shiny toys. One way to keep yourself honest is to consider the opportunity cost - ask yourself what more product-differentiating feature you could be working on if you were to buy the thing you're about to start building.

Some places where you should probably be defaulting to Buy rather than Build - at least in the early days of your product - include using a stock CMS for non-product pages, using a PaaS like Heroku for deployment, and using a hosted data store.

### Look beyond your experience
Don't forget to be humble and look outside the technology ecosystem you're comfortable with when assessing whether you should build something or buy it. When Twitter were first working through breaking apart their monolithic Rails system one of the first things they did was introduce asynchronous queues between systems - a very sound scaling decision. Unfortunately the Ruby ecosystem didn't have any great distributed queues at the time, and so Twitter engineers decided to [implement their own](https://github.com/starling/starling) using the technology they were comfortable with - Ruby. Hindsight being 20/20, they might have endured a few less fail whales if they had picked an existing distributed messaging technology that had already been proven to operate at the scale they needed.

If you need to add search to your Golang-based product, consider ElasticSearch before you start building your own inverted search index in Golang. If you're Scala product needs a rich web client, consider React and ES6 before you start building a cool UI framework in Scala.js.
