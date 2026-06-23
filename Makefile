all: data \
data/JTW/2023-census-main-means-of-travel-to-work-by-statistical-area.csv \
data/meshblock/2023-census-electoral-population-at-meshblock-level-2025-mes.shx \
data/meshblock/2023-census-electoral-population-at-meshblock-level-2025-mes.dbf \
data/meshblock/2023-census-electoral-population-at-meshblock-level-2025-mes.prj \
data/meshblock/2023-census-electoral-population-at-meshblock-level-2025-mes.cpg \
data/meshblock/2023-census-electoral-population-at-meshblock-level-2025-mes.shp.xz \
data/geographic-areas-table-2025.csv \
data/osm/new-zealand-latest.osm.pbf \
out

data:
	mkdir -p data

# Journey-to-work data
data/JTW/2023-census-main-means-of-travel-to-work-by-statistical-area.csv: data
	mkdir -p data/JTW
	curl -L https://raw.githubusercontent.com/STATS-UOA/statsnz-data/refs/heads/master/2023-census-main-means-of-travel-to-work-by-statistical-area/2023-census-main-means-of-travel-to-work-by-statistical-area.csv -o $@
	
# Meschblock population data
data/meshblock/2023-census-electoral-population-at-meshblock-level-2025-mes.shx: data
	mkdir -p data/meshblock
	curl -L -H "Accept: application/octet-stream" \
	https://raw.githubusercontent.com/STATS-UOA/statsnz-data/refs/heads/master/2023-census-electoral-population-at-meshblock-level-2025-meshblock/2023-census-electoral-population-at-meshblock-level-2025-mes.shx -o $@

data/meshblock/2023-census-electoral-population-at-meshblock-level-2025-mes.shp.xz: data/meshblock/2023-census-electoral-population-at-meshblock-level-2025-mes.shx
	curl -L -H "Accept: application/octet-stream" \
	https://raw.githubusercontent.com/STATS-UOA/statsnz-data/refs/heads/master/2023-census-electoral-population-at-meshblock-level-2025-meshblock/2023-census-electoral-population-at-meshblock-level-2025-mes.shp.xz -o $@
	unxz data/meshblock/2023-census-electoral-population-at-meshblock-level-2025-mes.shp.xz

data/meshblock/2023-census-electoral-population-at-meshblock-level-2025-mes.dbf: data/meshblock/2023-census-electoral-population-at-meshblock-level-2025-mes.shx
	curl -L -H "Accept: application/octet-stream" \
	https://raw.githubusercontent.com/STATS-UOA/statsnz-data/refs/heads/master/2023-census-electoral-population-at-meshblock-level-2025-meshblock/2023-census-electoral-population-at-meshblock-level-2025-mes.dbf -o $@

data/meshblock/2023-census-electoral-population-at-meshblock-level-2025-mes.prj: data/meshblock/2023-census-electoral-population-at-meshblock-level-2025-mes.shx
	curl -L -H "Accept: application/octet-stream" \
	https://raw.githubusercontent.com/STATS-UOA/statsnz-data/refs/heads/master/2023-census-electoral-population-at-meshblock-level-2025-meshblock/2023-census-electoral-population-at-meshblock-level-2025-mes.prj -o $@

data/meshblock/2023-census-electoral-population-at-meshblock-level-2025-mes.cpg: data/meshblock/2023-census-electoral-population-at-meshblock-level-2025-mes.shx
	curl -L -H "Accept: application/octet-stream" \
	https://raw.githubusercontent.com/STATS-UOA/statsnz-data/refs/heads/master/2023-census-electoral-population-at-meshblock-level-2025-meshblock/2023-census-electoral-population-at-meshblock-level-2025-mes.cpg -o $@

# Geographic areas table
data/geographic-areas-table-2025.csv: data
	mkdir -p data/JTW
	curl -L https://raw.githubusercontent.com/STATS-UOA/statsnz-data/refs/heads/master/statsnz-geographic-areas-table-2025/geographic-areas-table-2025.csv -o $@

# Open Street Maps
data/osm/new-zealand-latest.osm.pbf: data
	mkdir -p data/osm/cache
	curl -L -H "Accept: application/octet-stream" \
	https://download.geofabrik.de/australia-oceania/new-zealand-latest.osm.pbf -o $@
	
# Output directory
out:
	mkdir -p out


.PHONY: all