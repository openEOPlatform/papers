import openeo
# Connect to openEO Platform
con = openeo.connect("openeo.cloud")
# Load the Sentinel 2 bands 2, 4 and 8 for July 2022
datacube = con.load_collection(
    "SENTINEL2_L2A",
    spatial_extent = {"west": 7, "east": 9, "south": 51, "north": 52},
    temporal_extent = ["2022-07-01", "2022-08-01"],
    bands = ["B02", "B04", "B08", "SCL"]
)
# Remove clouds and saturared values using the Scene Classification layer
scl_band = datacube.band("SCL")
cloud_mask = (scl_band == 1) | (scl_band == 3) | (scl_band == 8) | (scl_band == 9)
datacube = datacube.mask(cloud_mask)
# Rescale from digital numbers to physical values
datacube = datacube.apply(process = lambda x: x * 0.0001)
# Compute the EVI over the bands dimension
B02 = datacube.band("B02")
B04 = datacube.band("B04")
B08 = datacube.band("B08")
datacube = 2.5 * (B08 - B04) / ((B08 + 6.0 * B04 - 7.5 * B02) + 1.0)
# Compute the maximum value over the temporal dimension
datacube = datacube.reduce_temporal("max")
# Save as GeoTiff files
result = datacube.save_result(format = "GTiff")
# Create a batch job at the backend
job = result.create_job()
# Apply further operations on the job
