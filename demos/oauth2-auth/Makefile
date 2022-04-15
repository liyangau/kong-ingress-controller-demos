.PHONY: install
install:
	./install.sh

.PHONY: test-all
test-all:
	@./test.sh

.PHONY: test-auth-code
test-auth-code:
	@./test.sh -t auth_code

.PHONY: test-implicit
test-implicit:
	@./test.sh -t implicit

.PHONY: test-password
test-password:
	@./test.sh -t password

.PHONY: test-client-cred
test-client-cred:
	@./test.sh -t client_cred

.PHONY: uninstall
uninstall:
	./uninstall.sh