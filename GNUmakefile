parser:
	flx flx_build_flxg.flx

small-test:
	build/flxg-tmp/parser.exe  -v --force --cache_dir=cash --output_dir=. \
	--syntax=@felix/build/release/share/lib/grammar/grammar.files \
	--include=felix/build/release/share/lib/ \
	hello.flx

big-test:
	build/flxg-tmp/parser.exe  -v --force --cache_dir=cash --output_dir=. \
	--syntax=@felix/build/release/share/lib/grammar/grammar.files \
	--include=felix/build/release/share/lib/ \
	flx_build_flxg.flx

