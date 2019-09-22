all:
	elm package install
	elm make src/Main.elm --output ../public/cocktails.js
	postcss css/main.css -o ../public/style.css

dev:
	elm package install
	elm make src/Main.elm --output ../public/cocktails.js --debug
	postcss css/main.css -o ../public/style.css
