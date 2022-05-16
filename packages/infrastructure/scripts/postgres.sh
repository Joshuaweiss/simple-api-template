PGPASSWORD=$(aws secretsmanager get-secret-value \
    --query SecretString \
    --output text \
    --secret-id $(terraform output -raw rds_password_secret_id)) \
psql \
    -h localhost \
    -p 5432 \
    -U "$(terraform output -raw master_username)" \
    $(terraform output -raw database_name)
