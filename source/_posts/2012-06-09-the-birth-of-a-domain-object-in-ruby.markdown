---
layout: post
title: "The Birth Of a Domain Object In Ruby"
date: 2012-06-09 00:58
comments: true
categories: 
---

Software designs doen't pop into existance fully formed. The evolve over time. In this post I'm going to show how a concept can grow from a lowly method parameter to an all-growed-up Domain Object.

## Initial requirements

Imagine we're building some code that will take bug reports from a user and submit them to a third-party bug tracking service. We expose an HTTP endpoint in a sinatra app to allow this:

``` ruby
post '/bug_report' do
   bug_description = params[:bug_description]

   BugFiler.report_bug( bug_description )
end
```

So far so good. BugFiler is some service code that takes a bug description string and makes the appropriate service call to create a bug with that description in our bug tracking system.

So the concept here is that of a **Bug**. So far it is represented by a string primitive and that's OK because that's all we need right now. Some java programmers would leap to their IDE keyboard shortcuts at this point and fix this Primitive Obsession code smell by refactoring this string primitive into a Bug type. But we're ruby programmers. We're pragmatttic. YAGNI.


## New requirements

Now our product guys have realized it'd be nice to know who is submitting these bug reports. They'd like use to track the name of the person filing the report. OK.


``` ruby
post '/bug_report' do
   bug_description = params[:bug_description]
   bug_reporter = params[:reporter]

   BugFiler.report_bug( bug_description, bug_reporter )
end
```

You can assume that we also modified `BugFiler#report_bug` to take that second arg. So now we're good. New requirements are satisfied and we can move on to our next task.


## More new requirements

Oh actually, the product folks have realized we should really be tracking severity too. OK.


``` ruby
post '/bug_report' do
   bug_description = params[:bug_description]
   bug_reporter = params[:reporter]
   severity = params[:severity]

   BugFiler.report_bug( bug_description, bug_reporter, severity )
end
```

So this works, but now alarm bells are ringing for me. 3 params is about my limit for maintainable code. Let's change `BugFiler#report_bug` to take a hash instead.


``` ruby
post '/bug_report' do
   bug_description = params[:bug_description]
   bug_reporter = params[:reporter]
   severity = params[:severity]

   BugFiler.report_bug({ 
     :description => bug_description, 
     :reporter => bug_reporter, 
     :severity => severity
     })
end
```

A bit more verbose, but I'd say more readable too.


## Default severity

Turns out that sometimes a user doesn't bother to explicitly specify a bug severity, so we should set that to a default of 'medium' by default.


``` ruby
post '/bug_report' do
   bug_description = params[:bug_description]
   bug_reporter = params[:reporter]
   severity = params[:severity] || 'medium'

   BugFiler.report_bug({ 
     :description => bug_description, 
     :reporter => bug_reporter, 
     :severity => severity
     })
end
```

## Deriving a bug summary

Our product friends are back. Turns out that our third party bug tracker allows us to specify a summary line describing the bug, but we don't currently have any UI exposed which lets users specify that summary. We'd like to work around this by just clipping the first line of text from the bug description and using that as the bug summary. OK, I think we can do that.

``` ruby
post '/bug_report' do
   bug_description = params[:bug_description]
   bug_reporter = params[:reporter]
   severity = params[:severity] || 'medium'

   bug_summary = bug_description.split("\n").first

   BugFiler.report_bug({ 
     :description => bug_description, 
     :reporter => bug_reporter, 
     :severity => severity,
     :summary => bug_summary
     })
end
```

## Replacing Primitive Obsession with a Struct

Now at this point I think we have too much logic in our controller code. It feels like we the beginnings of a domain object here. We don't want to disturb too much code as we initially introduce this new object, so we'll just replace the primitive hash we currently have with a Struct.


``` ruby
# elsewhere in the codez
Bug = Struct.new(:description,:reporter,:severity,:summary)

post '/bug_report' do
   bug_description = params[:bug_description]
   bug_reporter = params[:reporter]
   severity = params[:severity] || 'medium'

   bug_summary = bug_description.split("\n").first

   bug = Bug.new( bug_description, bug_reporter, severity, bug_summary )
   BugFiler.report_bug( bug )
end
```


We've used ruby's built in Struct facility to dynamically generate a `Bug` class which takes some parameters at construction and then exposes them as attributes. This type of class is variously referred to as a DTO or Value Object.

Note here that we would have also modified `BugFiler#report_bug` to expect a `Bug` instance rather than a raw hash.

## Introducing a Domain Object

We now have a Bug class, but it's just a boring old Value Object with no behaviour attached. Let's move the logic which is cluttering up our controller code into our Bug class.



``` ruby
# elsewhere in the codez
class Bug < Struct.new(:description,:reporter,:severity)
  def summary
    description.split("\n").first
  end

  def severity
    super || 'medium'
  end
end

post '/bug_report' do
   bug_description = params[:bug_description]
   bug_reporter = params[:reporter]
   severity = params[:severity]

   bug = Bug.new( bug_description, bug_reporter, severity )
   BugFiler.report_bug( bug )
end
```

This is one of my favorite ruby tricks. We define the class `Bug` which inherits from a dynamically created Struct class, and then we add in some extra behavior. This way we don't have to write boring initialize methods or attr_accessor code in our class definition, and our intent is clearly captured by the use of Struct.

# Solidifying our Domain Object

Now that we have a `Bug`, why don't we allow it to file itself?


``` ruby
class Bug < Struct.new(:description,:reporter,:severity)
  def summary
    description.split("\n").first
  end

  def severity
    super || 'medium'
  end

  def file_report!
    BugFiler.report_bug(self)
  end
end

post '/bug_report' do
   bug_description = params[:bug_description]
   bug_reporter = params[:reporter]
   severity = params[:severity]

   bug = Bug.new( bug_description, bug_reporter, severity )
   bug.file_report!
end
```

That seems quite nice. We have some controller logic which doesn't do much apart from transform params into an object and then call methods on that object.

At this point we have the beginnings of a real Domain Object in our `Bug` class. In the future we could add the ability to serialize a Bug instance to a flat file or a database, and not really need to touch our controller code. We can also test all of the business logic without needing to thing about HTTP mocking, `Rack::Test`, or anything like that.
