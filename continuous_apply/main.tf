module "continuous_apply_codebuild_role" {
  source     = "../module/aws/iam"
  name       = "continuous-apply"
  identifier = "codebuild.amazonaws.com"
  policy     = data.aws_iam_policy.administrator_access.policy
}

data "aws_iam_policy" "administrator_access" {
  arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_codebuild_project" "continuous_apply" {
  name         = "${var.project}-common-continuous-apply"
  service_role = module.continuous_apply_codebuild_role.iam_role_arn

  source {
    type      = "GITHUB"
    location  = "https://github.com/tasogare0919/terraform-sandbox.git"
    buildspec = "terraform/continuous_apply/buildspec.yml"
  }

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    type            = "LINUX_CONTAINER"
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "hashicorp/terraform:1.0.0"
    privileged_mode = false
  }

  provisioner "local-exec" {
    command = <<-EOT
      aws codebuild import-source-credentials \
        --server-type GITHUB \
        --auth-type PERSONAL_ACCESS_TOKEN \
        --token $GITHUB_TOKEN
    EOT

    environment = {
      GITHUB_TOKEN = data.aws_ssm_parameter.github_token.value
    }
  }
}

data "aws_ssm_parameter" "github_token" {
  name = "GITHUB_TOKEN"
}

resource "aws_codebuild_webhook" "continuous_apply" {
  project_name = aws_codebuild_project.continuous_apply.name

  filter_group {
    filter {
      type    = "EVENT"
      pattern = "PULL_REQUEST_CREATED"
    }

    filter {
      exclude_matched_pattern = false
      pattern                 = "^terraform/dev/"
      type                    = "FILE_PATH"
    }
  }

  filter_group {
    filter {
      type    = "EVENT"
      pattern = "PULL_REQUEST_UPDATED"
    }

    filter {
      exclude_matched_pattern = false
      pattern                 = "^terraform/dev/"
      type                    = "FILE_PATH"
    }
  }

  filter_group {
    filter {
      type    = "EVENT"
      pattern = "PULL_REQUEST_REOPENED"
    }

    filter {
      exclude_matched_pattern = false
      pattern                 = "^terraform/dev/"
      type                    = "FILE_PATH"
    }
  }

  filter_group {
    filter {
      type    = "EVENT"
      pattern = "PUSH"
    }

    filter {
      type    = "HEAD_REF"
      pattern = "develop"
    }

    filter {
      exclude_matched_pattern = false
      pattern                 = "^terraform/dev/"
      type                    = "FILE_PATH"
    }
  }
}