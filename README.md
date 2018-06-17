# Vlad's dotfiles

## Installation

### Dotfiles

```SH
git clone https://github.com/vladgh/dotfiles.git ~/dotfiles
~/dotfiles/install.sh
```

### Secrets

Stored in an AWS S3 bucket (requires [AWS Command Line Interface](https://docs.aws.amazon.com/cli/latest/reference/))

```SH
AWS_ACCESS_KEY_ID=ABCD AWS_SECRET_ACCESS_KEY=1234 SECRETS_S3_PATH=s3://myBucket SECRETS_LOCAL_PATH=~/mySecrets dotfiles/install.sh
```

## Contribute

See [CONTRIBUTING.md](CONTRIBUTING.md) file.

## License

Licensed under the Apache License, Version 2.0.
See [LICENSE](LICENSE) file.
