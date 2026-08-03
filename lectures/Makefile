DOC_DIRS := $(patsubst %/Makefile,%,$(wildcard week-*/L*/docs/Makefile))

.DEFAULT_GOAL := notes

.PHONY: notes clean list

notes:
	@for dir in $(DOC_DIRS); do \
		$(MAKE) -C "$$dir" notes || exit $$?; \
	done

clean:
	@for dir in $(DOC_DIRS); do \
		$(MAKE) -C "$$dir" clean || exit $$?; \
	done

list:
	@for dir in $(DOC_DIRS); do echo "$$dir"; done
