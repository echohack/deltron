# Deltron CHANGELOG

## 1.0.0 (06-28-2017)

## Features & Enhancements

This release focuses on making deltron even easier to use and includes some minor refactors.

- Pin to Terraform 0.9.9.
- Use the built in ~/.aws/credentials file by default. You can still set a profile using ${var.aws_profile}
- Generate a 4 byte random id that we add to tags in case you want to spin up multiple automate clusters.
- Move security rules into a separate file.
- Use high performance centos images.
- Automate calculate subnet from vpc. We pick the first one available.
- Move to using a built in installer for chef server.