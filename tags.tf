locals { 
  common_tags = { 
    environment     = "${lower(var.env)}" 
    project         = "AWS CI/CD Pipeline"
    managedby       = "TRENDS"
  } 
}