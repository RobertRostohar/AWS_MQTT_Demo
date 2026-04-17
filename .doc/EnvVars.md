# Environment Variables for the AWS IoT Thing

Environment variables can be set in different ways depending on the environment:

- For local development with command line tools, set the environment variables before building the project.
- For local development in VS Code with the Arm CMSIS Solution extension, configure them in the extension settings.
- When using GitHub Actions, provide the environment variables via [GitHub Secrets](https://docs.github.com/en/actions/security-for-github-actions/security-guides/using-secrets-in-github-actions).
- When using GitHub Codespaces, provide the environment variables via [Codespaces Secrets](https://docs.github.com/en/codespaces/managing-your-codespaces/managing-your-account-specific-secrets-for-github-codespaces).

## List of variables

Variable name                  | *AWS IoT Thing* information
:------------------------------|:---------------------------------------
`IOT_THING_NAME`               | Thing name
`MQTT_BROKER_ENDPOINT`         | MQTT broker endpoint (host name)
`ROOT_CA_PEM`                  | Server (host) root CA certificate
`CLIENT_CERTIFICATE_PEM`       | Client (device) certificate
`CLIENT_PRIVATE_KEY_PEM`       | Client (device) private key

## Format of variables

Before entering the variables it is necessary to format them as explained below.

Variable name                  | Original or issued format     | Variable format
:------------------------------|:------------------------------|:---------------------------------------
`IOT_THING_NAME`               | string                        | string i.e.  `myIoT_thing_name`
`MQTT_BROKER_ENDPOINT`         | string                        | string i.e.  `random-string.abcd.xyz.amazonaws.com`
`ROOT_CA_PEM`                  | Multiline string. See **F1**. | Single line string with additional new-lines. See **F2**.
`CLIENT_CERTIFICATE_PEM`       | Multiline string. See **F1**. | Single line string with additional new-lines. See **F2**.
`CLIENT_PRIVATE_KEY_PEM`       | Multiline string. See **F3**. | Single line string with additional new-lines. See **F4**.

**F1**: The issued Certificate format is a multiline string like:

```txt
-----BEGIN CERTIFICATE-----
::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::
-----END CERTIFICATE-----
```

**F2**: The expected Certificate format must be a singleline string. i.e.

```txt
-----BEGIN CERTIFICATE-----\n:::::::::::::::::::::::::::::::::::::::::::::::\n-----END CERTIFICATE-----\n
```

**F3**: The issued Private Key format is a multiline string like:

```txt
-----BEGIN RSA PRIVATE KEY-----
::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::
-----RSA PRIVATE KEY-----
```

**F4**: The expected Private Key format must be a singleline string. i.e.

```txt
-----BEGIN RSA PRIVATE KEY-----\n::::::::::::::::::::::::::::::::::::::::::::::\n-----END RSA PRIVATE KEY-----\n
```
