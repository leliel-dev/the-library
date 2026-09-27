#import "@preview/obelisk:0.2.0": *
#import "/shared/authors.typ": *

// obelisk tries to set "Inter" which defaults to another variant of the inter font
#show: init.with(fonts: (sans: "Inter Display"))
// obelisk 0.2.0 has leading for level 1 headings that produces clipping
#show heading.where(level: 1): set text(bottom-edge: -9pt)

= Setting up the library for Leliel

#{
  v-step(-3)
  set align(right)
  set text(14pt, font: "Inter", luma(30%))
  set par(leading: 20pt)
  [Frøya Lydersen]
}

== Aim
The goal of the library is to *document & communicate instances of thinking & work that has been done*, for:

- us in the future when we have forgotten
- future maintainers that join the project
- others interested in how we are doing things
- users interested in what we plan to do

The library will replace some, but not all, documentation. It also gives us a place for explorations, reflections, and reports on work.

#pagebreak()

== General Approach
We considered more of a blog or wiki, but we believe:

- We do not need realtime cooperative writing, i.e. git is enough for cooperation.
- Little time will be spent navigating to/between documents compared to reading and writing one document at a time.
- Few documents will benefit from being tightly integrated with other documents.
- We will want more layouting options than a simple markdown to html conversion can give us.
- Plain text is a large benefit.

Given this, a nicely presented list of pdfs was deemed suitable. It is also simply fun to make cool documents with typst!

== Concretely
=== Structure and publishing
Github "writeups" monorepo\[^2\], with a directory for each separate document, and probably a directory for typst templates and such. Also some metadata files in each document's directory.
- Nyas main concern with monorepo is tbh noisy commit history and a bajillion tags, but both of those can be mitigated by using git properly:
  - there should be a way to only see history as it relates to a directory
  - there should be a way to see what commit last changed this file
  - we can manually do per-document namespaces for our tags and filter in that way
- Of course we might have issues with 1 person doing breaking changes while another wants to build everything and publish new versions of stuff, for this usecase we should probably use branches
- We should try to rebase and keep a linear history
- Metadata files store, for each document:
  - list of statements of intent combined with date\[^1\]
  - title, authors, abstract/summary
  - a list of related documents + how they are related
- We make annotated tags for notable "versions" of documents.
  - Unsure how this should be presented on the website, but maybe it would be nice to be able to have a persistent link to a version of a document built from a tag.
2. A runner automatically tries to build all modified pdfs in the repo upon commits reaching main, if it fails to build then we are not notified, so as to not spam us while we are working on it, it just keeps the last good built pdfs.
  - This is kinda problematic,,, we do need a way to know if our changes made it to the site or not. "Notification on successful build" and "Notification on failure" both suffer from spamming us with redundant information. Maybe display something like _"document last built from source 2 days, 3 hours, 5 minutes, 19 seconds ago"_. (section below)
3. We have a site where we display all our pdfs
  - Along with info about them:
    - title, authors, abstract/summary
    - first&last modified/built
    - last statement of intent\[^1\]
    - a list of related documents + a note on how they are related
  - One overview, probably similar to typst universe in layout, with options to download a pdf, or:
  - Ability to view pdfs in browser without downloading.
  - Would be nice if this all didn't look terrible too..

**When do we publish a pdf? when is it "done"?**

Nya thinks waiting for "done" means it will never get published 80% of the time. plus there's some value in publishing writeups for projects we abandoned! But nya nyaself rarely knows when nya has abandoned a sideproject and when it is just on hold until nya can get back to it.

Nya thinks what we should do is publish right away, and let the "last modified" and "last statement of intent" speak for how relevant it is.

Nya earlier thought about having a split between "living" and "point release" documents. Like, a living reference to the current setup or hostnames or hardware would be a living document, but then we would also have some documents that are "finished and published", and become historical. But these two disjoint categories would not work out, so nya thinks all documents should be live, with checkpoints. Nya thinks this is a beautiful approach.

For example the following all fit within this system beautifully, without us having to pick between categories.

1. An old finished plan document
2. An abandoned unfinished exploration
3. A live and up to date reference

As follows:

1. We simply make the document without picking any category, then when we finish the document, we just make a tag for that version to signify it, and add a statement of intent that it is done and will become historical over time.
2. We simply make the document without picking any category. When life gets busy and we forget about it, the age of our last statement of intent in there racks up, and without us having to change its category or decide if it's "done" it can exist on the site, serving as a reference of our thoughts, waiting for us to potentially return, without being misleading to others or forcing us to decide if it's abandoned or not.
3. We simply make the document without picking any category, and keep updating it. The "last modified" and "last statement of intent" will clearly show it is a live document.

\[^1\]: Thoughts on **statement of intent**
Nya thought a lot about this and thinks this is the best approach.

```
nya originally thought about something like "status", or "superseded by". It would be useful because it says something about how relevant that document is right now, how we view it right now, and also lets you know if something has superceded it, but it is scary because any time we try to force disjoint categories (current vs superseded, up to date vs outdated, etc), elements that fit into both or do not cleanly fit into either are just waiting to appear (e.g. a document that is 90% current but 10% wrong).

Another idea was "last reviewed" and having regular reviews, but realistically if a review is hard to do then it won't happen, and if it is easy, for small fixes and such, then the word "review" betrays how quick of a glance will be given.

But nya still wants some pointer on like, when did we last look at this and go "yup, this is good!"? *Last modified/built* is one such pointer but it doesn't tell you that an old document that is simply done but still relevant is still relevant. What does "this is good" even mean?:
- "this is still true of the current fleet"
	- becomes false very very fast, so probably not smart
- "this will not mislead someone reading it today"
	- it is hard to decide if this is true. nya can read work in progress technical discussions from 2011 and not be mislead about where they ended up or the current state of fairs. nya feels an old document kinda *can't* be misleading? at worst it documents a plan that did not turn out, which is not a bad thing

We, and especially outsiders, would benefit from SOME cairns to find our way, lest the site end up feeling like a list of dubiously abandoned/unfinished documents. something telling you like, "yeah this is unfinished, we know, it's on the todo" vs "this is basically done/frozen" or something along those lines would be very helpful

Nya thinks what someone really needs to know is a statement of intent, and when it was written. It makes for the most elegant and functional solution nya has found to this whole thing. If someone sees that a document was last modified 5 months ago and the statement of intent was also at that time to continue working on it, then they have all they need and could get, to judge for themselves the current state of affairs. Simultaneously it is not a huge burden for us to add while working, nor after the fact. It is an approach that does not lie to any of its users.

Naively, nya is picturing the format for this metadata like `<timestamp> - <statement of intent>` per line, top line is latest one.
```
