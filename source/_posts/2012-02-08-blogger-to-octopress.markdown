---
layout: post
title: "Moving from Blogger to Octopress"
date: 2012-02-08 18:25
comments: true
published: false
categories: 
---

Yes, like many other dork bloggers I've jumped onto the [Octopress](http://octopress.org) bandwagon. 

A big concern I had with switching blogging platforms (I was previously on Blogger) was breaking links to my existing content. Part of my concern was in losing Google Juice (yes, I'm that vain), but I'm also aware that a couple of my posts about Frank have become sources of documentation which are linked to from a few different places on the web. I definitely did not want to break those links.

That said, my worries appear to have been groundless. I've been very plesantly surprised at how easy it has been to import my old posts into Octopress, maintaining the same urls. The first step was to export my existing content from Blogger. I went to the Settings section in my blog's admin pages and chose Other > Blog Tools > Export blog). Then I pulled down a copy of [this ruby script](https://gist.github.com/1578928) I found via a quick google search, and ran it against that exported file from Blogger. It very quickly generated a bunch of static posts from the exported Blogger data. It even used the same path format that Blogger uses, so no problem with broken links. Neat.

All in all, I'd say it took about 20 minutes to go from cloning the octopress repo to browsing all my old Blogger content in my shiny new Octopress blog. Really a very smooth experience.

