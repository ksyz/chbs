# :ok_hand: :horse: :battery: :paperclip:

Another [xkcd-936](https://xkcd.com/936/) inspired, correct horse battery staple (didn't found right emoji for staple) password generator. Copying under WTF-PL.

Required perl modules:

 * Math::Random::Secure
 * File::Slurp

Examples:

```sh
$ cbhs -w 3 -m 2 -M 4
rebs mori femf
$ cbhs -C -w 6
Funest Larunda Exudate Apachism Myopies Overyear
$ ./chbs -w 3 -c -1 -m7 -M9
synopsize trisected mikados
daishiki aceldamas nonfutile
drownding placets altumal
crellen garfield routinist
namaqua pioneer hypnoetic
outlies bedribble barcelona
betatter antagony hypoxis
deutsche laniidae winesops
^C
$ ./chbs -w 5 -m2 -d diceware8k.txt
elude gg dahl di cauchy
$ chbs --help
...
```

#### Lists
 * http://world.std.com/~reinhold/diceware8k.txt
 * /usr/share/dict/words

If in doubt, whether you will end in endless loop, check the word list capabilities with `wc -L $WORDLIST`, to determine exact limits for that word list. 

#### Warning :warning:
 * It's not a [diceware](http://world.std.com/~reinhold/diceware.html) implementation.
 * May end up in in infinite loop, if conditions could not be met with provided word list.
 * May run random amount of time.
 * May kill your kitten and/or burn your kitchen.
 * Module interface is subject to random changes
