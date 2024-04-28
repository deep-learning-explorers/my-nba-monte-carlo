install-uv:
	pipx install uv
	uv pip compile requirements.in > requirements.txt
	uv pip install -r requirements.txt

build: install-uv
	cd evidence && npm install
	mkdir -p data/data_catalog/raw
	mkdir -p data/data_catalog/prep
	mkdir -p data/data_catalog/simulator
	mkdir -p data/data_catalog/analysis

run:
	cd dlt && python nba_pipeline.py
	cd sqlmesh && sqlmesh plan --no-prompts --auto-apply
	cd evidence && npm run sources

dev:
	cd evidence && npm run dev -- --host 0.0.0.0

serve:
	rm -rf evidence/build
	cd evidence && npm run build:strict
	cd evidence && npm i -g http-server
	cd evidence && npx http-server ./build

evidence-build:
	cd evidence && npm run build

docker-build:
	docker build -t mdsbox .

docker-run-evidence:
		docker run \
		--publish 3000:3000 \
		--env MDS_SCENARIOS=10000 \
		--env MDS_INCLUDE_ACTUALS=true \
		--env MDS_LATEST_RATINGS=true \
		--env MDS_ENABLE_EXPORT=true \
		--env ENVIRONMENT=docker \
		mdsbox make run serve
