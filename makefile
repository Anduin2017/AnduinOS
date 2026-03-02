# Makefile —— AnduinOS build orchestrator
SHELL         := /usr/bin/env bash
.DEFAULT_GOAL := current

SRC_DIR       := src
CONFIG_DIR    := config

DEPS := \
  binutils \
  debootstrap \
  squashfs-tools \
  xorriso \
  grub-pc-bin \
  grub-efi-amd64 \
  grub2-common \
  mtools \
  dosfstools

.PHONY: all fast current clean bootstrap help

help:
	@echo "Usage:"
	@echo "  make          (or make current)   Build current language"
	@echo "  make all                          Build all languages"
	@echo "  make fast                         Build fast config languages"
	@echo "  make clean                        Remove build artifacts"
	@echo "  make bootstrap                    Validate environment and deps"

bootstrap:
	@if [ "$$(id -u)" -eq 0 ]; then \
	  echo "Error: Do not run as root"; \
	  exit 1; \
	fi
	@if ! lsb_release -i | grep -qE "(Ubuntu|Debian|Tuxedo|Anduin)"; then \
	  echo "Error: Unsupported OS — only Ubuntu, Debian, Tuxedo or AnduinOS allowed"; \
	  exit 1; \
	fi

	@missing="" ; \
	for pkg in $(DEPS); do \
	  if ! dpkg -s $$pkg >/dev/null 2>&1; then \
	    missing="$$missing $$pkg"; \
	  fi; \
	done; \
	if [ -n "$$missing" ]; then \
	  echo "Missing packages:$$missing"; \
	  echo "Installing missing dependencies..."; \
	  sudo apt-get update && sudo apt-get install -y$$missing; \
	else \
	  echo "[MAKE] All required packages are already installed."; \
	fi

current: bootstrap
	@echo "[MAKE] Building current language..."
	@cd $(SRC_DIR) && ./build.sh

all: bootstrap
	@echo "[MAKE] Building ALL languages (all.json)..."
	@./build_all.sh -c $(CONFIG_DIR)/all.json

fast: bootstrap
	@echo "[MAKE] Building FAST languages (fast.json)..."
	@./build_all.sh -c $(CONFIG_DIR)/fast.json

clean:
	@echo "[MAKE] Cleaning build artifacts..."
	@./clean_all.sh
	@echo "[MAKE] Clean complete."
