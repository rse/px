
PX 
==

**Python Environment Execution Utility**

**px** is a very small Unix utility for executing Python-based commands
(like `python` itself, its companion tools `pip`, `uv` and `uvx`, or
arbitrary third-party commands) while directing Python and PIP/UV to a
dedicated global-like local installation tree.

The crux is that the used global installation trees under `~/.px/`
are writable instead of the usually non-writable default one (under
e.g. `/opt/local`). Additionally, the `--update` option allows to
conveniently update all globally installed PIP/PIPX/UV packages/tools.

Installation
------------

```
$ make install
```

Usage
-----

```
# setup environment
$ px foo --create
$ px foo uv tool install bar

# use environment
$ px foo python [...]
$ px foo pip [...]
$ px foo uv [...]
$ px foo uvx [...]

[...]

# check and update environment
$ px foo --list
$ px foo --update

[...]

# destroy environment
$ px foo --destroy
```

Example
-------

```
# setup tool environment
$ px tool --create

# install Mistral Vibe
# (https://github.com/mistralai/mistral-vibe)
$ px tool uv tool install mistral-vibe

# install TOAD
# (https://github.com/batrachianai/toad)
$ px tool uv tool install -U batrachian-toad

# install Aider
# (https://aider.chat)
$ px tool uv pip install audioop-lts
$ px tool uv tool install -U aider-chat

# use the tools
$ px tool vibe [...]
$ px tool toad [...]
$ px tool aider [...]
```

See Also
--------

For Node.js, check out the sibling utility [**nx**](https://github.com/rse/nx).

Copyright & License
-------------------

Copyright &copy; 2025 [Dr. Ralf S. Engelschall](mailto:rse@engelschall.com)<br/>
Licensed under [MIT](https://spdx.org/licenses/MIT)

