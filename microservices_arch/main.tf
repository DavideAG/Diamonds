module "EC2" {
  source = "./Module/EC2"
}

module "kinesis_stream" {
  source = "./Module/kinesis_stream"
}