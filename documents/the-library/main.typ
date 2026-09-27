#import "@preview/ilm:2.1.1": *

#set text(lang: "en")
#show link: set text(rgb("#812e2b"))
#show: ilm.with(
  title: [Making the library for the Leliel project],
  authors: "~Frøya",
  date: datetime(year: 2026, month: 9, day: 27),
  abstract: [
    We the maintainers of the Leliel project need a place to put explorations, reflections, and reports on work, as well as a way to write them. My solution to this is a page on the site showing a list of documents made with typst, which I am calling "the library".
  ],
  // bibliography: bibliography("refs.bib"),
  figure-index: (enabled: false),
  table-index: (enabled: false),
  listing-index: (enabled: false),
  table-of-contents: none,
  raw-text: (font: "IosevkaTerm NF"),
  chapter-pagebreak: false,
)

= Aim
The goal of the library is to *document & communicate instances of thinking & work that has been done*, for:

- us in the future when we have forgotten
- future maintainers that join the project
- others interested in how we are doing things
- users interested in what we plan to do

The library will replace some, but not all, documentation. It also gives us a place for explorations, reflections, and reports on work.

= High level approach
We considered more of a blog or wiki, but we believe:

- We do not need realtime cooperative writing, i.e. git is enough for cooperation.
- Little time will be spent navigating to/between documents compared to reading or writing one document at a time.
- We will not benefit much from tightly integrating documents.
- We will want more layouting options than a simple markdown to html conversion can give us.
- Plain text is a large benefit.

Given this, a nicely presented list of pdfs was deemed suitable. It is also simply fun to make cool documents with typst!

= Concretely
== Structure of the library
The library is a monorepo #footnote[Monorepo because it's generally easier to manage and automate working with (e.g. compiling N documents) than N small repos. Also easy to share components and do work across multiple documents.], with a directory for each separate document. There will also be some metadata files in each document's directory.

My main concern with using a monorepo is 1. noisy commit history, and 2. ending up with a bajillion tags. I think both of those can be mitigated by using git properly:

- there should be a way to only see history as it relates to a directory
- there should be a way to see what commit last changed this file
- we can manually do per-document namespaces for our tags and filter in that way

Of course we might have issues with 1 person doing breaking changes while another wants to build everything and publish new versions of stuff. For this usecase we should probably use branches. Otherwise it is worth mentioning that we should try to rebase and keep a linear history.

We make annotated tags for notable "versions" of documents.

#pagebreak()

The metadata files will store, for each document:
- a list of statements of intent + dates for them
- title, authors, abstract/summary
- a list of related documents + how they are related

== Publishing of documents

A runner automatically tries to build all modified pdfs in the repo upon commits reaching main, we are not notified when it succeeds nor when it fails, so as to not spam us while we are working on it, instead we can check "last built" on the live site. In the event of a build failure it just keeps the last good built pdfs.

== The library site

A site under `leliel.dev` with an overview of documents, similar to typst universe in layout. By clicking on a document, you can view it in the browser without downloading it. In the overview each document will show:
- List of versions for a document?
- title
- authors
- abstract/summary
- first built
- last built
- last statement of intent
- a list of related documents + a note on how they are related

= Reflections on usage
== When do we publish a pdf? when is it "done"?

I think waiting for "done" means a document will never get published 80% of the time. Plus there's some value in publishing writeups for projects we abandoned! But even I myself rarely know when I've abandoned a sideproject, and when it is just on hold until I can get back to it.

I think what we should do is publish right away, and let the "last modified" and "last statement of intent" speak for how relevant it is today.

I earlier thought about having a split between "living" and "point release" documents. Like, a living reference to the current setup or hostnames or hardware would be a living document, but then we would also have some documents that are "finished and published", that would become historical over time. But #link("https://karl-voit.at/2017/04/18/classification/")[Logical Disjunct Categories Don't Work], so I think all documents should in principle be live, and be point released by nature of simply not having been updated.

#pagebreak()

The following all fit within this system beautifully, without us having to pick between categories.

1. An old finished plan document
2. An abandoned unfinished exploration
3. A live and up to date reference

As follows:

1. We simply make the document without picking any category, then when we finish the document, we just make a tag for that version to signify it, and add a statement of intent that it is done and will become historical over time.
2. We simply make the document without picking any category. When life gets busy and we forget about it, the age of our last statement of intent in there racks up, and without us having to change its category or decide if it's "done" it can exist in the library, serving as a reference of our thoughts, waiting for us to potentially return, without being misleading to others or forcing us to decide if it's abandoned or not.
3. We simply make the document without picking any category, and keep updating it. The "last modified" and "last statement of intent" will clearly show it is a live document.


== Thoughts on statement of intent
I thought a lot about this and think this is the best approach.

I originally thought about something like "status", or "superseded by". It would be useful because it says something about how relevant that document is right now, how we view it right now, and also lets you know if something has superceded it, but it is scary because any time we try to force disjoint categories (current vs superseded, up to date vs outdated, etc), elements that fit into both or do not cleanly fit into either are just waiting to appear (e.g. a document that is 90% current but 10% wrong).

Another idea was "last reviewed" and having regular reviews, but realistically if a review is hard to do then it won't happen, and if it is easy, for small fixes and such, then the word "review" betrays how quick of a glance will be given.

But I still want to offer some pointer on like, when did we last look at this and go "yup, this is good!"? *Last modified/built* is one such pointer but it doesn't tell you that an old document that is simply done but still relevant is still relevant. What does "this is good" even mean?
- "This is still true of the current fleet."\
  Becomes false very very fast, so probably not a relevant question to ask.
- "This will not mislead someone reading it today."\
  It is hard to decide if this is true. I can read work in progress technical discussions from 2011 and not be mislead about where they ended up or the current state of fairs. I feel an old document kinda *can't* be misleading? at worst it documents a plan that did not turn out, which is not a bad thing.

#pagebreak()

Maintainers, and especially others, would benefit from SOME cairns to find our way, lest the library end up feeling like a list of dubiously abandoned/unfinished documents. Something telling you "yeah this is unfinished, we know, it's on the todo" vs "this is basically done/frozen" or something along those lines would be very helpful. But how?

I thinks what someone really needs is a statement of intent, and knowledge of when it was written. It makes for the most elegant and functional solution I've found to this whole thing. If someone sees that a document was last modified 5 months ago and the statement of intent was also at that time to continue working on it, then they have all they need and could get, to judge for themselves the current state of affairs. Simultaneously it is not a large burden for us to add while working, nor after the fact. It is an approach that seems to work well for all of its users.

Naively, I picture the format for this metadata like `<timestamp> - <statement of intent>` per line, top line is latest one, but I do want us to use an existing format like toml so we can simply deserialize.
