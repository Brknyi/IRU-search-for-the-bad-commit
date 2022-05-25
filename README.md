# Első hibás commit megkeresése

## Feladatleírás

Két, nem közvetlenül egymást követő, git commit id-je alapján 
határozza meg bináris kereséssel annak a két megadott commit
között levő commitnak az id-jét, ahol a cége fejlesztői
elrontották a VS-ban írt C++ programjukat. A hibát arról lehet
megismerni, hogy a filters állományban az egyik konfliktus
feloldása során kimaradt egy </ItemData> lezáró tag.

## Megoldás

A feladat megoldása során a git beépített tool-ját, a git bisect-et használtam. Ez bináris keresést használva keresi meg a problémát okozó commit-ot. A megtaláláshoz a hibát még nem tartalmazó és a hibát már tartalmazó utolsó commit-ra van szüksége,amelyek között elvégzi a keresést.

### Tesztkörnyezet

A megoldásomat egy Visual Studio 2019-ben készített c++ console alkalmazás projekt fájljában teszteltem. Ebben a .filters állományban több jelentéktelen módosítással készítettem commit-okat a teszteléshez, amelyek között megtalálható a feladat leírásában is leírt.

A generált commit-ok között a hibás ID-je: 72a0dae3649087efe712ba769cc709422b8dbc36

### A script

```
#!/bin/bash

good_commit=$1      # Utolsó hibát még nem tartalmazó commit ID-je
bad_commit=$2       # A hibát tartalmazó commit ID-je

git bisect start > logs.txt                 # Elindítjuk a git bisect folyamatát
git bisect good $good_commit >> logs.txt    # Megjelöljük az utolsó még jó commit-ot
git bisect bad $bad_commit >> logs.txt      # Megjelöljük a záró commit-ot mint feltételezett hibásat
# Megadjuk a pranacsnak, hogy mi alapján tesztelje az egyes commit-okhoz tartozó állapotokat
git bisect run sh -c '[ "`grep -inrc --include \*.filters  "<ItemData>"`" =  "`grep -inrc --include \*.filters  "</ItemData>"`" ]' >> logs.txt
# Ha a log fájl tartalmaz olyan sort, amelyben a folyamat kiírta a sikeres eredményt akkor azt kiírjuk
if [ "`grep "is the first bad commit" logs.txt`" ]
then
	echo "The ID of the first bad commit: " `awk '/is the first bad commit/ {print $1}' logs.txt`	
else
# Mivel nem találtunk eredményt a teljes folyamat log-ját kiírjuk a felhasználónak
	echo "A problem is occurred. The log of the script: "
	cat logs.txt
fi
# Lezárjuk a git bisect folyamatát
git bisect reset >> temp.txt 2>&1
# Töröljüka  log fájlt
rm logs.txt
```

Mint látható a feladat teljes mértében az előbb leírtak szerint git bisect-et használ. Az érdekesség talán az, hogy a git bisect run-al script is megadható az eszköznek, amely alapján el tudja dönteni hogy adott commit-nak megfelelő állapotban fennált-e a probléma. Ennél az sh és -c kapcsolókkal kiegészítve inline paranccsal is képes voltam használni az eszközt. A feladat során a problémát az okozta, hogy az </ItemData> lezárótag hiányzott. Ezt minden esetben egy egyszerű grep-es kifejezéssel oldottam meg, ahol megnézem hogy a nyitó és záró tag-ek száma megegyezik-e. Ez minden .filters állományt megnéz a könyvtáron belöl. Az egységes kimenet biztosítása érdekében az egyes script-en belüli parancsok kimenetét egy fájlba vezettem át, majd azt végül minden esetben törlöm is.

### Futtatás

A parancs futtatása során kettő parancs argumentumot kell megadni adott sorrendben. Az első az utolsó még jó commit, a második pedig már a hibát tartalmazó.

Esetünkben: 

```
./conflict_fixer.sh 68b2ac715b237625825ac4bdab5a434eb8fc07bc 209857fb7d4f13448a9be29caafc4cac9e52e733
```

Kimenet:

```
The ID of the first bad commit:  72a0dae3649087efe712ba769cc709422b8dbc36
```

A parancs ezen repository-ban futtatható, mivel a teszteléshez hazsnálható commit-okat tartalmazza.