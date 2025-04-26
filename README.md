# SampleApp

A sample web app made for learning purposes.


## Notes:

This project was initiated using the legacy version of the Phoenix-1.6 framework
with the goal of studying the available open-source materials and completely
reproducing the project from scratch on this older version, without spending
time on adjustments for newer versions. The intent is to fully grasp the
underlying concepts before purposefully transitioning to a more up-to-date
version.

The release of Phoenix framework version 1.6.2 was on October 9, 2021, followed
by the next minor version (1.7.0) released on February 24, 2023. However, it
became evident that to start a new project in `2025` with such old dependencies,
additional modifications to the `mix.lock` file must be made. Otherwise, some
transitive dependencies (dependencies of dependencies) may pull in versions
that are too new and incompatible with others, resulting in broken compilation
or runtime errors.

To address the versioning issue, I specified the exact versions of all required
dependencies directly(mix.exs), based on the release date of the main project
dependency, `phoenix-1.6.2`. To automate this process, I developed a simple
command-line [tool](https://github.com/edmtsky/fix_mix_lock) that allows
obtaining the versions of dependencies as they existed at a specific historical
moment in the past, effectively simulating an installation at that point in time
(specifically between the releases of phoenix-1.6.2 and 1.6.3).




To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).


## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix


## Setup details

See [steps to setup the old Phoenix version(1.6.2)](./doc/00-setup.md)



## TODOList

- [-] update all dependencies to version phoenix-1.6.16
