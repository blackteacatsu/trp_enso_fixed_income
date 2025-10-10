# JHU X T.Rowe Price Climate Impact on Sovereign Debt 

A research collaboration between Johns Hopkins University (Whiting School’s Department of Civil & Systems Engineering and Earth & Planetary Sciences) and T. Rowe Price to study how climate variability influences macroeconomic indicators and sovereign debt risk.

### Common issue with dataset
If xarray gives the following error when reading dataset,

```bash
OSError: [Errno -101] NetCDF: HDF error: '/vast/bzaitch1/trp_climate_model_data/era5land_1970_2024/1970_02.nc' 
```

then try ```os.environ["HDF5_USE_FILE_LOCKING"] = "FALSE" ``` and ```os.environ["NETCDF_HDF5_FILE_LOCKING"] = "FALSE"``` before reading any data to make suare that HDF5 locking is disabled.

## Citing / Acknowledgments

If you use this work, please cite the project announcement:

“Weathering the Financial Storm: Johns Hopkins Experts Partner with T. Rowe Price to Investigate Climate Impact on Sovereign Debt,” Johns Hopkins University, Feb 17, 2025. 
engineering.jhu.edu

Partners: Johns Hopkins University (CaSE; Earth & Planetary Sciences) and T. Rowe Price. 
engineering.jhu.edu