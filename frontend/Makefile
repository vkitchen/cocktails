all:
	elm package install
	elm make src/Main.elm --output ../backend/public/tophat.js
	postcss css/main.css -o ../backend/public/style.css

dev:
	elm package install
	elm make src/Main.elm --output ../backend/public/tophat.js --debug
	postcss css/main.css -o ../backend/public/style.css
