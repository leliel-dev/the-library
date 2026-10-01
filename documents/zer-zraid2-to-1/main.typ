#import "@preview/ilm:2.1.1": *

#set text(lang: "en")
#show link: set text(rgb("#812e2b"))
#show: ilm.with(
  title: [Dropping zeruel from ZRAID2 to ZRAID1],
  authors: "~Frøya",
  date: datetime(year: 2026, month: 9, day: 29),
  abstract: [
    When I set up zeruel's ZFS pool a while ago, I had no offsite to send backups to, and I wasn't comfortable with less than RAIDZ2. But now I do, so RAIDZ1 is sufficient! Here I document the move.
  ],
  // bibliography: bibliography("refs.bib"),
  figure-index: (enabled: false),
  table-index: (enabled: false),
  listing-index: (enabled: false),
  table-of-contents: none,
  raw-text: (font: "IosevkaTerm NF"),
  chapter-pagebreak: false,
)

= How did we get here?
For most of my life I've been dragging around a bunch of data on a bunch of SSDs, thumbdrives, and SD cards, that have _somehow_ never failed. Nov '25 I realized how fragile this is and how sad I would be to lose precious vidoes from when I was a kid, so I decided I needed a reliable storage solution.

Cloud options seemed expensive in the long run, and I like digital autonomy. Redundancy ain't backups, but with no option in my budget to take backups, I wasn't willing to store data with less redundancy than for 2 simultaneous drive failures. I bought some used hard drives for cheap, but half of the ones I received were DOA, and the rest were drawing their final breaths. That wasn't gonna cut it, so by mid Dec '25, four brand new 4tb WD Red Plus drives had arrived by mail.

I went with ZFS, more specifically RAIDZ2, because it seemed like an all-round flexible, capable, safe way to store data. It addresses all my direct needs, does a bit more#footnote[For one, the checksumming should in theory help with bit-rot!.. Though now it doesn't practically seem to me like bitrot is a thing that happens. Atomic writes are nice though!], and also provides logical volume management functionality and snapshotting. On the 18. Dec '25 I had finished moving all my data off my SSDs and into the pool attached to my (then) arch system, and made a snapshot, `tank/terminaldogma/secondbranch@move_complete`. At some point after that I moved them into `zeruel`.

Nowadays I'm pooling my hardware with friends for self hosting, which means I have a place to send backups! `nakara`, another server under Leliel, is in a completely different part of the city, and has different model harddrives, bought several months after I bought mine. For this reason, we decided that `zeruel` and `nakara`, our two main servers, will both run RAIDZ1, and send backups to each other of important datasets.

This way, assuming we survive the resilver, we have tolerance for one drive failure at each location without a service interruption#footnote[We can simply run a degraded pool until a replacement HDD arrives.\ Fun fact, did you know ZFS can use a drive with a mortal wound as a reduced, but still functional source of redundancy, while resilvering a fresh disk? https://github.com/openzfs/zfs/discussions/18846#discussioncomment-17774885]. If another fails before the resilver completes, we do not lose data due to the backup offsite, unless _two or more fail at the other site as well, simultaneously_. That scenario is out of our budget for now!

We actually decided on this several months ago, and have been slowly doing little things over several weeks, but we haven't had time to finish it, nor write it down, until now.

#pagebreak()
= The first transfer

ZFS does not have a good story of dropping from RAIDZ2 to RAIDZ1, and the decision to do RAIDZ1 was made after `nakara` was kitted out with its dual 8tb drives, so we thought the best way to do it was to transfer all the data from `zeruel` to `nakara`, verify that all is well, destroy and remake the vdev on `zeruel`, and transfer the data back.

Given that there was `1.53T` to send, we originally considered sneakernet. But we (me and bunya) measured our speeds (possibly speed between us too, I don't remember), and it was only going to take on the order of 0.8 to 4 days, so we opted to send it over network instead.

ZFS can send snapshots with `zfs send`/`receive`, which supposedly has checksumming built in. On top of that, it's running over SSH and thus TCP, so I would be very surprised if there was data corruption/loss from sending.

On the 14. Aug '26 I made a snapshot, `tank/terminaldogma/secondbranch@tonakara`, and I believe I sent it with the following command:
```
$ sudo zfs send -cLe tank/terminaldogma/secondbranch@tonakara | nix run nixpkgs#pv -- -s 1888894178640 | ssh mend@nakara "zfs receive -s -u tank/received/tonakara"
```
I piped it through `pv` so I could have some visual indicator of progress, and I think I used the following command to get that number `1888894178640`:
```
$ sudo zfs send -nvP tank/terminaldogma/secondbranch@tonakara
```
That completed without any obvious problems, and then we took a break from it.

= Verifying the first transfer
== Nightmare nightmare nightmare <nightmare>
Looking at it at time of writing, on zeruel and nakara:
```
mend@zeruel $ zfs get used,refer tank/terminaldogma/secondbranch@tonakara
NAME                                      PROPERTY    VALUE  SOURCE
tank/terminaldogma/secondbranch@tonakara  used        1.06G  -
tank/terminaldogma/secondbranch@tonakara  referenced  1.53T  -
```

#v(1em)

```
mend@nakara $ zfs get used,refer tank/received/tonakara@tonakara
NAME                             PROPERTY    VALUE  SOURCE
tank/received/tonakara@tonakara  used        0B     -
tank/received/tonakara@tonakara  referenced  1.52T  -
```
They are.. different size. `1.52T` vs `1.53T`. Despite everything.

I poked around in the files but couldn't really find anything that looked wrong. Every file I tried to open on `nakara`'s version was just as fine as it was on `zeruel`. I couldn't find a single missing folder or file. I also ran a scrub on both, but neither reported any issue. So I can't trivially _find_ what's different, but there _should_ be a roughly 1 gibibyte difference!

== Hashing the whole datasets
_Obviously_ the best way to find out if they're really identical, is to hash each entire dataset. After all, it's only \~1.5 tebibyte each!#footnote[`T` means `TiB` in ZFS https://github.com/openzfs/zfs/issues/11046]

I mounted the dataset on both `zeruel` and `nakara`, navigated into them, and ran:#footnote[I LIED! I actually redirected to `/etc/nixos/terminal-dogma/data/res` and moved it afterwards :v]

```
# find . -type f -print0 | env LC_ALL=C sort -z | xargs -0 b3sum -- > /home/mend/old-dataset-full-hash
```

This basically recursively finds every file's path#footnote[Including secret/dot files!], sorts to get a consistent order#footnote[As the manpage for `sort` says, _"The locale specified by the environment affects sort order. Set `LC_ALL=C` to get the traditional sort order that uses native byte values."_ (not that it should matter, since `nakara` and `zeruel` are very similar software-wise, but scary!)], and then hashes them all, and writes it to a file of paths+hashes. If we then hash those files of hashes, and the resulting hash on both machines is identical, then nya reasons the actual files must be bit for bit identical when it comes to contents, path, and name. So let's check:

```
snuppy@lilin $ echo (ssh nakara "b3sum old-dataset-full-hash") \n (ssh zeruel "b3sum old-dataset-full-hash")
50e9c9d66a51fefaefcae67743e2125bcda121438b0899344afcdd32c29d2c0c  old-dataset-full-hash
 50e9c9d66a51fefaefcae67743e2125bcda121438b0899344afcdd32c29d2c0c  old-dataset-full-hash
```

I also ran the following command, and it had empty output:
```
snuppy@lilin $ diff (ssh nakara "b3sum old-dataset-full-hash" | psub) (ssh zeruel "b3sum old-dataset-full-hash" | psub)
```

So! How, if the hashes are identical, can they be different size?

What I suspect is that something about record size, block size, compression settings, etc, means that the space TAKEN UP is subtly different, even though the contents of the datasets on both machines is identical. Beyond that I don't know :D
#pagebreak()
== One last mystery

If you remember back to @nightmare, `zeruel` actually lists `1.06G` `used`, i.e. data that is uniquely stored in the snapshot, data that is different from current state on disk. Nothing should have been writing to it, and I sure didn't, so how did that happen?

Not to worry, I'll just make a snapshot of the current contents:

```
sudo zfs snapshot tank/terminaldogma/secondbranch@checklater
```

..and have zfs diff its contents against the old snapshot!

```
sudo zfs diff tank/terminaldogma/secondbranch@tonakara tank/terminaldogma/secondbranch@checklater
```

But when it completed, it listed no differences! So, somehow, `@tonakara` has `1.06G` of unique data, and yet, comparing its contents, it is IDENTICAL with what is on disk now.#footnote[The new snapshot showed 0B `used` after creation, so it has no unique data, and it was just created, so I can't see why its contents wouldn't be 100% faithful to the current state of the pool.]

What I think happened here is that when we earlier hashed all the contents, a lot of files were "read", which updated their `atime` (which was enabled on `zeruel`, though I intend to turn it off when I set up `RAIDZ1`), and this amounts to `1.06G` of metadata changed. I don't know, I'm not entirely sure how to check, but the actual contents haven't changed according to `zfs diff`, and nothing _should_ have gotten written, so even if data was written, I don't care about it.

= The fate of destruction is also the joy of rebirth
We are at the scary part - nuking the pool and recreating it. Better hope no accidental data loss slipped past our checks earlier, because if something didn't make it to `nakara` by now, then we're gonna lose it now! That title is an evangelion reference by the way.
