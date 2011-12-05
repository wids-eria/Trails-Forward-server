
Vilas County is broken down into 963,976 square single acre tiles (cells).  This amounts to 713 rows (y) and 1352 columns (x).  
The CSV file references tiles by it's x,y coordinate pair, stored as "ROW" and "COL" in the file, starting in the upper left corner (NW) and moving right (E).
Including the header, the CSV file has 963,977 lines and is roughly 50MB in size.


OUTPUT COLUMNS
================
LANDCOV2001 - Land cover class code for 2001 (see below)
LANDCOV2006 - Land cover class code for 2006 (see below)
IMPERV%2001 - Percent impervious surface (developed)  between 0 and 100 in 2001
IMPERV%2006 - Percent impervious surface (developed)  between 0 and 100 in 2006
CANOPY%2001 - Percent canopy cover between 0 and 100 in 2001
HOUSES1996 - Number of buildings on tile in 1996 (0 - 16)
HOUSES2005 - Number of buildings on tile in 2005 (0 - 16)
HDEN40 - Housing density class code for 1940 (see below)
HDEN50 - Housing density class code for 1950 (see below)
HDEN60 - Housing density class code for 1960 (see below)
HDEN70 - Housing density class code for 1970 (see below)
HDEN80 - Housing density class code for 1980 (see below)
HDEN90 - Housing density class code for 1990 (see below)
HDEN00 - Housing density class code for 2000 (see below)

!!!!!----- For all output data columns, 255 is a NODATA value ------!!!!!


LANDCOVER CLASS CODE DEFINITIONS (15 classes)
============================================
11 = Open Water
21 = Developed, Open Space
22 = Developed, Low Intensity
23 = Developed, Medium Intensity
24 = Developed, High Intensity
31 = Barren Land
41 = Deciduous Forest
42 = Coniferous Forest
43 = Mixed Forest
52 = Shrub / Scrub
71 = Grassland / Herbaceous
81 = Pasture / Hay
82 = Cultivated Crops
90 = Woody Wetlands
95 = Emergent Herbaceos Wetlands

See URL for in depth class descriptions:
http://www.mrlc.gov/nlcd_definitions.php


HOUSING DENSITY CLASS CODES
===========================
0 = No housing / Uninhabited	(0 houses per sq. km)
1 = Very Low Housing Density	(>0 to 2 houses per sq. km)
2 = Low Housing Density	(>2 to 4 houses per sq. km)
3 = Medium Housing Density	(>4 to 8 houses per sq. km)
4 = High Housing Density	(>8 to 16 houses per sq. km)
5 = Very High Housing Density	(>16 to 128 houses per sq. km)
6 = Intensely High Housing Density	(>128 houses per sq. km)
99 = Open Water