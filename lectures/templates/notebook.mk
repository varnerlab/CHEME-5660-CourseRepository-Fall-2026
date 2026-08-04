# Shared build rules for projector-friendly CHEME 5660 lecture notebooks.

NOTEBOOK ?=
HTML ?= $(NOTEBOOK:.ipynb=.html)
NBCONVERT ?= jupyter nbconvert
TEMPLATE_DIR ?= ../../templates
TEMPLATE_FILE ?= lecture-notebook.html.j2
TEMPLATE_CSS ?= lecture-notebook.css

ifeq ($(strip $(NOTEBOOK)),)
$(error Set NOTEBOOK before including lectures/templates/notebook.mk)
endif

.DEFAULT_GOAL := lecture

.PHONY: lecture clean

lecture: $(HTML)

$(HTML): $(NOTEBOOK) $(TEMPLATE_DIR)/$(TEMPLATE_FILE) $(TEMPLATE_DIR)/$(TEMPLATE_CSS)
	$(NBCONVERT) --to html --template lab \
		--template-file $(TEMPLATE_FILE) \
		--TemplateExporter.extra_template_paths=$(TEMPLATE_DIR) \
		--output $@ $(NOTEBOOK)

clean:
	$(RM) $(HTML)
