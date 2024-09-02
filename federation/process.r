library(openeo)
# Connect to openEO Platform
con = connect(host = "https://openeo.cloud")
# Create a process builder
p <- processes()
# Load the Sentinel 2 bands 2, 4 and 8 for July 2022
datacube <- p$load_collection(
  id = "SENTINEL2_L2A",
  spatial_extent = list(west=7, east=9, south=51, north=52),
  temporal_extent = c("2022-07-01", "2022-08-01"),
  bands=c("B02", "B04", "B08", "SCL")
)
# Remove clouds and saturared values using the Scene Classification layer
masking = function(data, context = NULL) {
  scl <- x[4]
  saturated = p$eq(x = scl, y = 1)
  cl_shadows = p$eq(x = scl, y = 3)
  cl_mprob = p$eq(x = scl, y = 8)
  cl_hprob = p$eq(x = scl, y = 9)
  return(p$or(x = p$or(x = p$or(x = saturated, y = cl_shadows), y = cl_mprob), y = cl_hprob))
}
cloud_mask = p$reduce_dimension(data = datacube, dimension = "bands", reducer = masking)
datacube = p$mask(data = datacube, mask = cloud_mask)
# Rescale from digital numbers to physical values
rescale <- function(x, context) p$multiply(x = x, y = 0.0001)
apply1 = p$apply(data = datacube, process = rescale)
# Compute the EVI over the bands dimension
evi_ <- function(x, context) {
  b2 <- x[1]
  b4 <- x[2]
  b8 <- x[3]
  return((2.5 * (b8 - b4)) / ((b8 + 6 * b4 - 7.5 * b2) + 1))
}
datacube <- p$reduce_dimension(data = datacube, reducer = evi_, dimension = "bands")
# Compute the maximum value over the temporal dimension
max_ <- function(data, context) { p$max(data) }
datacube <- p$reduce_dimension(data = datacube, reducer = max_, dimension = "t")
# Save as GeoTiff files
result <- p$save_result(data = datacube, format = "GTiff")
# Create a batch job at the backend
job <- create_job(graph = result)
# Apply further operations on the job
