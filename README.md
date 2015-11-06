# :ok_hand: :horse: :battery: :paperclip:

Another [xkcd-936](https://xkcd.com/936/) inspired, correct horse battery staple (didn't found right emoji for staple) password generator. Some [holy war](http://security.stackexchange.com/a/62842) reading. Copying under WTF-PL.

Required perl modules:

 * Crypt::Random::TESHA2 (replacement for Math::Random::Secure, which is not available in Enterprise Linux 7, with some backported irand() functionality)
 * File::Slurp

Compatible with at least Fedora 21 or Enterprise Linux 6. There is rpm copr [repo](https://copr.fedoraproject.org/coprs/ksyz/Acme-CHBS/) available. 

#### Examples:

```sh
$ cbhs -w 3 -m 2 -M 4
rebs mori femf
$ cbhs -C -w 6
Funest Larunda Exudate Apachism Myopies Overyear
$ chbs -s-
rory-bauge-ajaja-assise-hassled
$ chbs -s-:_\$ -R
bargeer_cora_acystia_lycee:mest
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

##### Local language based dictionary
It may be (is? insert potato here) much easier, to memoryse passphrases, not based on english ditionary for not native english speakers, meaning, in their mother language. In this case is used worlist, based on frequency of words from Slovak wikipedia dump. [id/psycho](http://p.brm.sk/sk_wordlist/) did the heavy lifting in this part, and prepared word packages. Wordlist `dict/dw-sk-8k.txt` contains 8192 most frequent words (3 to 6 character, inclusive), based on provided slovak wordlists.

```sh
$ CHBS_DICT=dict/dw-sk-8k.txt dwgen 
granat obraz ziskom moct bombu
$ chbs -s- -d dict/dw-sk-8k.txt 
mpc-zuby-paci-tunely-marsu
```

#### Warning :warning:
 * It's not a [diceware](http://world.std.com/~reinhold/diceware.html), or at least, I didn't care, to make one.
 * May end up in in infinite loop, if conditions could not be met with provided word list.
 * May run for random amount of time.
 * May kill your kitten and/or burn your kitchen.
 * Module interface is subject to random changes.
