resource "aws_security_group" "stag_sg_mnps_dashboard_euc1" {
  provider    = aws.eu-central-1

  name        = "stag_sg_mnps_dashboard_euc1"
  description = "Allow inbound traffic for mnps dashboard"
  vpc_id      = data.aws_vpc.eu-central-1-vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  tags = {
    BillingTeam = "ctooffice"
    Team        = "ctooffice"
    Name        = "stag_sg_mnps_dashboard_euc1"
  }
}

module "mnpsDashboardLambdaFunction" {
  source = "../../../modules/lambda"
  region        = "eu-central-1"
  function_name = "mnps-dashboard-lambda"

  create_package = false

  image_uri    = "737963123736.dkr.ecr.eu-central-1.amazonaws.com/browserstack/mnps_dashboard:v0.0.1"
  package_type = "Image"

  tags = {
    "BillingTeam" = "ctooffice",
    "Team" = "ctooffice",
    "Name" = "mnps_dashboard"
  }

  attach_policies    = true
  number_of_policies = 2

  policies = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole",
    "arn:aws:iam::737963123736:role/minion-team-ctooffice-stag"
  ]

  vpc_security_group_ids = [aws_security_group.stag_sg_mnps_dashboard_euc1.id]
  vpc_subnet_ids         = tolist(data.aws_subnets.pvt_apps_bstack_subnet.ids)

}

resource "aws_lambda_function_url" "mnpsDashboardUrl" {
  provider           = aws.eu-central-1

  function_name      = module.mnpsDashboardLambdaFunction.lambda_function_arn
  authorization_type = "NONE"
}
