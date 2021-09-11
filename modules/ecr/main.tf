resource "aws_ecr_repository" "main" {
  name = var.service_name
}

resource "aws_ecr_lifecycle_policy" "main" {
  repository = aws_ecr_repository.main.name

  policy = jsonencode(
    {
      "rules" : [
        {
          "rulePriority" : 1,
          "description" : "Keep last 30 release tagged images.",
          "selection" : {
            "tagStatus" : "tagged",
            "tagPrefixList" : ["release"],
            "countType" : "imageCountMoreThan",
            "countNumber" : 30
          },
          "action" : {
            "type" : "expire"
          }
        }
      ]
  })
}
