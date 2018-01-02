all:
	-cp -r _site/* ./
	-rm -rf _site/*
	-git add .
	-git commit -m "new blog"
	-git push origin master
