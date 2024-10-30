.PHONY:
.DEFAULT_GOAL := help

EXTENSION_ID="onedrive@logonoff.co"

define PRINT_HELP_PYSCRIPT
import re, sys
print("\x1b[1m%-20s\x1b[0m%s" % ("usage:", "make [COMMAND]"))
print("\x1b[1m%-20s %s\x1b[0m" % ("COMMAND", "Description"))
for line in sys.stdin:
	match = re.match(r'^([a-zA-Z_-]+):.*?## (.*)$$', line)
	if match:
		target, help = match.groups()
		print("\x1b[92m%-20s \x1b[0m%s" % (target, help))
endef
export PRINT_HELP_PYSCRIPT

help:
	@python3 -c "$$PRINT_HELP_PYSCRIPT" < $(MAKEFILE_LIST)

debug_log: ## Debug log
	@journalctl -f -o cat GNOME_SHELL_EXTENSION_UUID=$(EXTENSION_ID)

test_nested: ## Test extension in nested Gnome Shell
	@dbus-run-session -- gnome-shell --nested --wayland

locale_build: ## Build locale
	@for po_file in po/*.po; do \
		lang=$$(basename $$po_file .po); \
		msgfmt $$po_file -o locale/$$lang/LC_MESSAGES/OneDrive.mo; \
	done

locale_update: ## Update locale
	@xgettext --no-location -o po/OneDrive.pot *.js && \
	for po_file in po/*.po; do \
		lang=$$(basename $$po_file .po); \
		msgmerge --no-location --previous --silent $$po_file po/OneDrive.pot --output $$po_file; \
	done

install: ## Install extension
	@rm -rf ~/.local/share/gnome-shell/extensions/$(EXTENSION_ID) &&\
	cp -R . ~/.local/share/gnome-shell/extensions/$(EXTENSION_ID)

build: ## Build without login
	@gnome-extensions pack --extra-source=imgs --podir=po --force

# lg - Extension lg manager, run ALT+F2
