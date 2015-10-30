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
$ chbs --help
...
```

#### Warning :warning:
 * May end up in in infinite loop, if conditions could not be met with provided word list
 * May run random amount of time.
 * May kill your kitten and/or burn your kitchen
