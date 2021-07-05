resource "aws_dynamodb_table" "alessi-giorgio-prediction-diamonds-table" {
  name           = "prediction-diamonds-table"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "PredictionId"
  /* range_key      = "GameTitle" */

  attribute {
    name = "PredictionId"
    type = "S"
  }

  /* attribute {
    name = "GameTitle"
    type = "S"
  } */

  /* attribute {
    name = "TopScore"
    type = "N"
  } */

  ttl {
    attribute_name = "TimeToExist"
    enabled        = false
  }

  /* global_secondary_index {
    name               = "GameTitleIndex"
    hash_key           = "GameTitle"
    range_key          = "TopScore"
    write_capacity     = 10
    read_capacity      = 10
    projection_type    = "INCLUDE"
    non_key_attributes = ["UserId"]
  } */

  tags = {
    Name        = "prediction-diamonds-table"
    Environment = "production"
  }
}