## Dynamic Databrick's Spark cluster config

{
        "num_workers": 1,
    "spark_version": "7.3.x-scala2.12",
    "node_type_id": "Standard_DS3_v2",
    "driver_node_type_id": "Standard_D3_v2",
    "spark_env_vars": {
        "PYTHONPATH": "/databricks/spark/python/lib/py4j-0.10.9.1-src.zip:/databricks/spark/python:/databricks/spark/bin/pyspark",
        "PYSPARK_DRIVER_PYTHON": "/databricks/python3/bin/python3",
        "PYSPARK_PYTHON": "/databricks/python3/bin/python3"
    }
}