---
layout: post
title: "marker branches in git"
date: 2012-08-09 21:40
comments: true
categories: 
---

## A sample git branch progression
To illustrate how this works I'll step through the lifecycle of a build artifact for a hypothetical blog repo. In these diagrams the rounded boxes are git commits, the rectangles are git branches. The 'WD' rounded box represents local changes in the current working directory.

<figure>
  {% img /images/post_images/octopress_cd/1.png %}
  <figcaption>
    starting state
  </figcaption>
</figure>

At the start of this scenario the branches in our git repo indicate that prod currently contains the blog as of commit C2 and pre-prod contains the blog as of C4. We have committed some changes since then which haven't been pushed to an environment, and we also have some local changes which haven't been committed at all yet.

I want to showcase what's currently on the tip of my master branch, so I run `push_preprod master` to deploy the commit which *master* is pointing to into the preprod environment. After that script runs my git repo will look like the below.

<figure>
  {% img /images/post_images/octopress_cd/2.png %}
  <figcaption>
    after deploying to pre-prod
  </figcaption>
</figure>

The *prod* branch hasn't changed, but *pre-prod* has been updated to point to the same commit as *master*, since that's the commit which my script just successfully deployed to the pre-prod environment.

Note that I am able to deploy even though I also have local changes which I haven't committed. That's because my build and deploy scripts work in a temporary directory using a *copy* of the blog's source to build the static site, rather than working from my own local working directory of the repo.



