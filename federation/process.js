import { OpenEO, Formula } from '@openeo/js-client';
// Connect to openEO Platform
const con = await OpenEO.connect("https://openeo.cloud");
// Create a process builder
const builder = await con.buildProcess();
// Load the Sentinel 2 bands 2, 4 and 8 for July 2022
let datacube = builder.load_collection(
  "SENTINEL2_L2A",
  {west: 7, east: 9, north: 52, south: 51},
  ["2022-07-01", "2022-08-01"],
  ["B02", "B04", "B08", "SCL"]
);
// Remove clouds and saturared values using the Scene Classification layer
function masking(data) {
  const or = this.or.bind(this);
  const eq = this.eq.bind(this);
  const scl = this.array_element(data, null, "SCL");
  return or(or(or(eq(scl, 1), eq(scl, 3)), eq(scl, 8)), eq(scl, 9));
}
const cloudmask = builder.reduce_dimension(datacube, masking, "bands");
datacube = builder.mask(datacube, cloudmask);
// Rescale from digital numbers to physical values
datacube = builder.apply(datacube, new Formula("x*0.0001"));
// Compute the EVI over the bands dimension
datacube = builder.reduce_dimension(datacube, new Formula("(2.5 * ($B08 - $B04)) / (($B08 + 6 * $B04 - 7.5 * $B02) + 1)"), "bands");
// Compute the maximum value over the temporal dimension
function max_(data) {
  return this.max(data);
}
datacube = builder.reduce_dimension(datacube, max_, "t");
// Save as GeoTiff files
const result = builder.save_result(datacube, "GTiff");
// Create a batch job at the backend
const job = await con.createJob(result);
// Apply further operations on the job
