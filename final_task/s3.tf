
resource "aws_s3_bucket" "data-buck" {
  bucket = "data-buck-finaltask"
}


# bucket for athena 

resource "aws_s3_bucket" "athena-query-results-bucket" {
  bucket = "results-buck-for-athena"
}
