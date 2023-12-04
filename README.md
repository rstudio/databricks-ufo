# DataBricks UFO Quarto Dashboard and Shiny App

This is a Shiny app that allows you to explore the [National UFO Reporting Center](http://www.nuforc.org/) database
that is hosted on a [Databricks](https://databricks.com/) cluster.
The app is deployed via [Posit Connect](https://posit.co/products/enterprise/connect/).


## Installation / Setup

### Databricks Setup

- When creating a DataBricks compute cluster, make sure to select the `ML Runtime` option
and version `14.1`.
  - Later versions can be supposed, but the matching python package
needs to be published on PyPI first: <https://pypi.org/project/databricks-connect/>
- The runtime and version will be automatically picked up by the `pysparklyr` package,
  when you specify the `cluster_id` in the `install_databricks()` function.

### Environment variables with `.Renviron`

In a project `.Renviorn` or system `.Renviron` file,
define the following 3 variables:

```
DATABRICKS_CLUSTER_ID="databricks-cluster-id"
DATABRICKS_HOST=rstudio-partner-posit-default.cloud.databricks.com
DATABRICKS_TOKEN="Databricks-api-token"
```

the `DATABRICKS_HOST` and `DATABRICKS_TOKEN` are variable that may be implicitly in your connection code.
The `DATABRICKS_CLUSTER_ID` is set if you have multiple people collaborating on the codebase with separate
cluster IDs.

### Package Setup

You can install all the necessary packages with the following commands.

```r
remotes::install_github("mlverse/pysparklyr")
pysparklyr::install_databricks(cluster_id = Sys.getenv("DATABRICKS_CLUSTER_ID"))
```

#### Package Setup ARM Macs

If you are using an ARM mac,
you need to make sure Python `3.11.x` is installed on your system and point to that version before installing
`pysparklyr::install_databricks()`.
This is because the python `torch` package is not compatiable on ARM Macs in any other Python version (at time of writing).

Install Python `3.11.5` via `pyenv`:

```bash
pyenv install 3.11.5
```

You can then install `pysparklyr`.

```r
pysparklyr::install_databricks(cluster_id = Sys.getenv("DATABRICKS_CLUSTER_ID"), as_job = FALSE, python_version = "3.11.5")
```

You should see:

```
Automatically naming the environment:'r-sparklyr-databricks-14.1'
```

and

```
+ ~/.pyenv/versions/3.11.5/bin/python3.11 -m venv ~/.virtualenvs/r-sparklyr-databricks-14.1
```

In your install output.


## Deploy application to Connect

```r
rsconnect::deployApp(
  appDir = here::here("ufo-shiny"),
  # set the python path (you need to change this value yourself
  python = "/Users/danielchen/.virtualenvs/r-sparklyr-databricks-14.1/bin/python",
  envVars = c("DATABRICKS_HOST", "DATABRICKS_TOKEN", "DATABRICKS_CLUSTER_ID"),
  lint = FALSE
)
```

```r
rsconnect::deployApp(
  appDir = here::here("ufo-dashboard"),
  # set the python path (you need to change this value yourself
  python = "/Users/danielchen/.virtualenvs/r-sparklyr-databricks-14.1/bin/python",
  envVars = c("DATABRICKS_HOST", "DATABRICKS_TOKEN", "DATABRICKS_CLUSTER_ID"),
  lint = FALSE
)
```
