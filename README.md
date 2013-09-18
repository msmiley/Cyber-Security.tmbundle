# Hex Tools TextMate 2 bundle

A TextMate 2 bundle with Commands, Syntaxes, and Snippets tailored for working with hex data in the context of the best text editor out there, TextMate 2.

## Caveats

### Ruby Version

This TextMate bundle jumps the gun a little bit by requiring Ruby >= 1.9.3 even though TextMate runs bundle items using Ruby 1.8.7 from Mac OS X system folders.

TextMate can be forced to use Ruby >= 1.9.3 by adding the path to the `ruby` binary to the front of the PATH variable in TextMate preferences, e.g. `/usr/local/var/rbenv/versions/2.0.0-p247/bin/`

Rumor is OS X Mavericks will ship with Ruby 2.0 so we should be able to cut out the shenanigans soon.

### Binary .dylib
This TextMate bundle contains a pre-compiled .dylib in the Support folder. Source for this dylib will be available separately soon and should hopefully be ported to Ruby.
