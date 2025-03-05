
resource "aws_glue_catalog_database" "emp_detail" {
  name = "emp_detail"
}
/*
resource "aws_glue_catalog_table" "emp_table" {
  name          = "emp"
  database_name = aws_glue_catalog_database.emp_detail.name

  table_type = "EXTERNAL_TABLE"
  parameters = {
    classification = "parquet"
  }

  storage_descriptor {
    columns {
      name = "id"
      type = "string"
    }
    columns {
      name = "name"
      type = "string"
    }
    columns {
      name = "contact"
      type = "string"
    }
    columns {
      name = "department"
      type = "string"
    }
    columns {
      name = "email"
      type = "string"
    }
  }
}
*/

resource "aws_glue_crawler" "emp_crawler" {
  name          = "emp-detail-crawler"
  role          = aws_iam_role.glue_role.arn  # Ensure this role has S3 & Glue permissions
  database_name = aws_glue_catalog_database.emp_detail.name
  table_prefix  = "emp_table" # Prefix for tables created by the crawler

  s3_target {
    path = "s3://data-buck-finaltask/data/"
  }



  configuration = jsonencode({
    Version = 1.0
    Grouping = { TableGroupingPolicy = "CombineCompatibleSchemas" }
  })
}


