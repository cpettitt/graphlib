NODE?=node
NPM?=npm
BROWSERIFY?=node_modules/browserify/bin/cmd.js
MOCHA?=node_modules/mocha/bin/mocha
MOCHA_OPTS?=
JS_COMPILER=node_modules/uglify-js/bin/uglifyjs
JS_COMPILER_OPTS?=--no-seqs
GENDOCS=node_modules/gendocs/bin/gendocs

MAIN_JS=graphlib.js
MAIN_MIN_JS=graphlib.min.js

# There does not appear to be an easy way to define recursive expansion, so
# we do our own expansion a few levels deep.
JS_SRC:=$(wilcard lib/*.js lib/*/*.js lib/*/*/*.js)
JS_TEST:=$(wildcard test/*.js test/*/*.js test/*/*/*.js)

all: $(MAIN_JS) $(MAIN_MIN_JS) test

$(MAIN_JS): Makefile browser.js lib/version.js node_modules $(JS_SRC) api_docs
	@rm -f $@
	$(NODE) $(BROWSERIFY) browser.js > $@
	@chmod a-w $@

$(MAIN_MIN_JS): $(MAIN_JS)
	@rm -f $@
	$(NODE) $(JS_COMPILER) $(JS_COMPILER_OPTS) $< > $@
	@chmod a-w $@

lib/version.js: src/version.js package.json
	$(NODE) src/version.js > $@

node_modules: package.json
	$(NPM) install

api_docs: 
	$(GENDOCS) ./lib/Graph.js > api.md

.PHONY: test
test: $(MAIN_JS) $(JS_TEST)
	$(NODE) $(MOCHA) $(MOCHA_OPTS) $(JS_TEST)

clean:
	rm -f $(MAIN_JS) $(MAIN_MIN_JS)
