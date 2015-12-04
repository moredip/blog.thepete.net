---
layout: post
title: "DIY stir plate for homebrew yeast starters"
date: 2015-12-03 22:07
comments: true
categories: 
---

I brew beer as a hobby, and one of the secrets to really good homebrew is happy, healthy, plentiful yeast at the start of fermentation. Creating a yeast starter really helps with this, and a good yeast starter requires a stir plate to keep the yeast in suspension.

Stir plates aren't *super* expensive, but at [around](http://www.northernbrewer.com/maelstrom-stir-plate) [100USD](http://www.morebeer.com/products/hanna-magnetic-stir-plate.html) they're not something you'd buy on a whim. I found a lot of information online on how to make your own DIY stir plate using an old computer fan and some magnets, and since I also like tinkering with electronics I decided to give it a go. After a couple of design iterations I'm really happy with how this project turned out.

{% img /images/post_images/stirplate/IMG_7318.JPG %}
{% img /images/post_images/stirplate/IMG_7327.JPG %}

# The internals

This is a pretty simple piece of electronics. In terms of components we have:

* a $10 [**aluminum project box**](http://www.amazon.com/gp/product/B00CH9Q60U?psc=1&redirect=true&ref_=oh_aui_search_detailpage)
* a **12 volt computer fan** (sometimes called a squirrel fan or muffin fan) liberated from an old computer
* a **9 volt DC power supply** which I scavenged from somewhere (note **NOT** 12V, which would spin the fan too fast for our purposes)
* a $3 [**panel mount barrel jack**](https://www.adafruit.com/products/610) for the power supply
* a **panel mount potentiometer, plus knob** (maybe $2?) to act as a voltage divider to control the fan's speed
* a $0.50 [**panel mount switch**](https://www.sparkfun.com/products/11138) for a power switch
* a **steel washer** which I hot-glued to the computer fan
* two [**rare-earth magnets**](http://www.homedepot.com/p/Master-Magnetics-1-2-in-Neodymium-Rare-Earth-Magnet-Discs-6-per-Pack-07046HD/202526367) ($4 for 6), which are stuck to that washer just with magnetism.
* a few **strands of wire** to build our simple circuit

{% img /images/post_images/stirplate/IMG_7322_annotated.jpeg %}

here's a circuit diagram showing how the electronics are assembled. 

{% img /images/post_images/stirplate/circuit.png %}

Pretty simple, which is good for me since I'm not an electronics whiz. I have read in [another guide](http://www.stirstarters.com/instructions.html) that it's not a good idea to use just a simple pot-based voltage divider to adjust the speed since it will be pulling a lot of wattage when the speed is turned down. However with my current configuration I usually leave the stir plate at pretty much full blast anyway with a 9V supply, so I'm not too worried.

# Building it

I hot-glued a steel washer to the computer fan, then attached the two magnets about 1" apart. Next I did a dry-run assembly of the circuit and tested that the fan spun and I could control speed with the potentiometer. Next I put the fan in the project box and tested that it was able to spin a [small magnetic stir bar](http://www.northernbrewer.com/stir-bar-round-25mm) inside my Erlenmeyer flask. 

Once I knew the basic functionality was there I started assembling the stir plate for real. I started off by attaching the computer fan to the base of the project box with a square of [foam mounting tape](http://www.target.com/p/scotch-double-sided-tape-1in-x-50in/-/A-14792269). Then I drilled holes in the aluminum project box for my panel-mount power switch, potentiometer and barrel jack. I used a small drill bit to make a pilot hole followed by a step drill bit to widen the hole. Once I had all the components in place I just needed to solder a few wires and the project was pretty much complete.

For a final touch I added some clear rubber feet to the base of the box to reduce vibration when the stir plate is running.

{% img /images/post_images/stirplate/IMG_7320.JPG %}

All in all this probably took me 4 hours of time, spread over a couple of weekends. I'm really very happy with the result. It works well and it actually looks like a professional job, something that's very rare for things I make with my own hands! It even got a seal of approval from my Junior Homebrewer friend.

{% img /images/post_images/stirplate/IMG_7336.JPG %}
