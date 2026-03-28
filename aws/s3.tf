# ── S3 Bucket für Terraform Remote State ─────────────────
resource "aws_s3_bucket" "terraform_state" {
  # Bucket-Name muss global unique sein — deinen Namen einbauen!
  bucket = "${var.project_name}-terraform-state-${var.aws_account_id}"

  # Verhindert versehentliches Löschen via terraform destroy
  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name      = "Terraform State Bucket"
    ManagedBy = "terraform"
  }
}

# ── Versionierung — jede State-Änderung wird gespeichert ──
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# ── Verschlüsselung — State enthält sensitive Daten ───────
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# ── Kein public Access — State darf nie öffentlich sein ───
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket                  = aws_s3_bucket.terraform_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ── DynamoDB für State Locking ─────────────────────────────
resource "aws_dynamodb_table" "terraform_lock" {
  name         = "${var.project_name}-terraform-lock"
  billing_mode = "PAY_PER_REQUEST"   # kostenlos bei wenig Nutzung
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = { Name = "Terraform State Lock" }
}
