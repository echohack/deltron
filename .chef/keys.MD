# Validator keys

Place pre-generated delivery validator key in this directory.

`delivery-validator.pem` - should be a private key
`delivery-validator.pub` - should be generated off the private key using the command: `openssl rsa -in delivery-validator.pem -pubout -out delivery-validator.pub`
