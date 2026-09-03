.PHONY: all build check public-check preview social-card check-social-card release-assets check-release-assets clean

all: check

build:
	./scripts/build.sh

check: check-release-assets check-social-card
	./scripts/check.sh

public-check: check
	./scripts/check-public.sh

preview: build
	./scripts/preview.sh

social-card:
	./scripts/render-social-card.sh

check-social-card:
	./scripts/render-social-card.sh --check

release-assets: build
	./scripts/check.sh
	./scripts/package-release.sh

check-release-assets: build
	./scripts/package-release.sh --check

clean:
	rm -f dist/Claudiu_Schuster_CV_DE.pdf \
		dist/Claudiu_Schuster_CV_EN.pdf \
		dist/Claudiu_Schuster_CV_DE_EN_preview.png \
		dist/Claudiu_Schuster_CV_social_card.png \
		dist/SHA256SUMS
