:warning: Please, do not unnecessary download wikipedia's dump files. 

Use [WikiExtractor.py](http://medialab.di.unipi.it/Project/SemaWiki/Tools/WikiExtractor.py) on decompressed ``XXwiki-latest-pages-articles.xml``. Then use ``wordstats.pl``, which will output CSV with number of occurrences and word in second field. This is intuitive implementation and may consume huge amount of memory. Will not work on non-latin based dumps.

```sh
mkdir wikidump
python WikiExtractor.py XXwiki-latest-pages-articles.xml --processes 3 -o wikidump --no-templates
perl wordstats.pl | tee wordstats.txt | cut -d, -f2 | sort > tee dw-XX-8k.txt
```
