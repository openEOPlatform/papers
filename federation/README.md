# Federated and reusable processing of Earth observation data

This folder contains additional material for the paper following paper:

> Federated and reusable processing of Earth observation data by Mohr et al.

The following examples show how a use case can be expressed in three different programming languages, along with the JSON process graph it will be converted into.
This process can be sent to the openEO Platform aggregator and it can be distributed to and run by any of the server implementations that the aggregator is connected to.
For simplicity, we skip the authentication steps in the examples.
The examples show how maximum Enhanced Vegetation Index (EVI) values can be found from pixel time series of Sentinel 2 imagery.

- [Python client library code](process.py)
- [R client library code](process.r)
- [JavaScript client library code](process.js)
- [JSON-encoded process description](process.json)
