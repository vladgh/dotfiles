dotfiles
========

[![Join the chat at https://gitter.im/vladgh/dotfiles](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/vladgh/dotfiles?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

## Installation

```bash
git clone --recursive https://github.com/vladgh/dotfiles.git
cd dotfiles
source install.sh
```

## Bugs

Please report any bugs to: https://github.com/vladgh/dotfiles/issues

## Contributing:

Open an issue or a pull request if you see how we can improve the script.

Guidelines:

  - Respect the style described at http://wiki.bash-hackers.org/scripting/style

  - Use [ShellCheck](http://www.shellcheck.net/about.html) to verify your code

  - Each function should be prefixed with the name of the script:
    `{script_name}_{function_name}`
    EX: `aws_install_cli()` (where aws.sh is the filename)

  - Each function should be documented in this format:

    ```
    # NAME: name_of_function
    # DESCRIPTION: A description of what it does
    # USAGE: name_of_function {param1} {param2}
    # PARAMETERS:
    #   1) describe each parameter (if any)
    ```

  - If the script exports a variable it should be prefixed with the name of the
    script, all in capital letters with underscores.
    EX: DOCKER_COMPOSE_VERSION (where docker.sh is the filename)
    KEEP THESE TO A MINIMUM!
