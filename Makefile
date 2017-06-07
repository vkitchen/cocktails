all:
	elm package install
	elm make src/Main.elm --output public/tophat.js
