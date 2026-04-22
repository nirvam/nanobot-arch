.PHONY: build-arch deploy-quadlet clean-quadlet status

# 基础镜像名 (不含冒号)
IMAGE_REPO = localhost/nanobot
# 默认 Tag
DEFAULT_TAG = arch
# 组合全名
IMAGE_NAME = $(IMAGE_REPO):$(DEFAULT_TAG)

# Quadlet 路径 (用户模式)
QUADLET_DIR = $(HOME)/.config/containers/systemd

build-arch:
	@echo "Building Arch-based Podman image from PyPI..."
	podman build --build-arg BUILD_DATE=$(shell date +%Y%m%d) -t $(IMAGE_NAME) -f Containerfile.arch .

build-tag:
	@if [ -z "$(TAG)" ]; then echo "Usage: make build-tag TAG=0.1.4.post6"; exit 1; fi
	@echo "Building Arch-based Podman image for tag $(TAG)..."
	podman build --build-arg BUILD_DATE=$(shell date +%Y%m%d) --build-arg VERSION=$(TAG) -t $(IMAGE_REPO):$(TAG)-arch -f Containerfile.arch .

deploy-quadlet: build-arch
	@echo "Deploying Quadlet to $(QUADLET_DIR)..."
	mkdir -p $(QUADLET_DIR)
	cp nanobot.container $(QUADLET_DIR)/
	@echo "Reloading systemd user daemon..."
	systemctl --user daemon-reload
	@echo "Starting nanobot service..."
	systemctl --user start nanobot.service
	@echo "Done. Service nanobot is now managed by systemd."

clean-quadlet:
	@echo "Removing Quadlet and stopping service..."
	systemctl --user stop nanobot.service || true
	rm -f $(QUADLET_DIR)/nanobot.container
	systemctl --user daemon-reload
	@echo "Cleaned up."

status:
	@systemctl --user status nanobot.service
