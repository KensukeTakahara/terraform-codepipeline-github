resource "aws_codestarconnections_connection" "main" {
  name          = "github-connection"
  provider_type = "GitHub"
}
