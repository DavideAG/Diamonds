resource "aws_dynamodb_table" "alessi-giorgio-prediction-diamonds-table" {
  name           = "prediction-diamonds-table"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "PredictionId"

  attribute {
    name = "PredictionId"
    type = "S"
  }

  ttl {
    attribute_name = "TimeToExist"
    enabled        = false
  }

  tags = {
    Name        = "prediction-diamonds-table"
    Environment = "production"
  }
}