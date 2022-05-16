ssh \
    -L 5432:$(terraform output -raw rds_endpoint):5432 \
    bastion@$(terraform output -raw bastion_endpoint)
