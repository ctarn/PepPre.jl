name="PepPre"
content="tmp/$(uname -m).$(uname -s)"
shared="tmp/shared"
out="tmp/release/$name-$(cat $content/$name/VERSION).$(uname -m).$(uname -s)"
rm -rf $out
pyinstaller ui/$name.py -Fwy -i fig/$name.png --distpath $out --workpath tmp/build
mkdir $out/content
cp -R $content/* $shared/* $out/content/
rm -rf $name.spec
