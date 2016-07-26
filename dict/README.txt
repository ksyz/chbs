mkdir wikidump
# http://medialab.di.unipi.it/Project/SemaWiki/Tools/WikiExtractor.py
./WikiExtractor.py cswiki-latest-pages-articles.xml --processes 3 -o wikidump --no-templates
perl wordstats.pl | tee wordstats.txt | cut -d, -f2 | sort > tee dw-cs-8k.txt
