routes:
	mix phx.routes

run:
	mix phx.server

run-iex:
	iex -S mix phx.server

test:
	mix test

# using wix_test_watch
testw:
	mix test.watch
