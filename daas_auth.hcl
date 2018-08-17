path "secret/*" {
  policy = "write"
}

path "secret/daas_auth" {
  policy = "read"
}

path "auth/token/lookup-self" {
  policy = "read"
}
