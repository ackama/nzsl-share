# Contributing

Although we are always happy to make improvements, we also welcome changes and
improvements from the community!

Have a fix for a problem you've been running into or an idea for a new feature
you think would be useful? Here's what you need to do:

1. Fork this repo and clone your fork to somewhere on your machine.
1. [Ensure that you have a working environment](#setting-up-your-environment).
1. Read up on the [architecture of the application](#architecture),
   [how to run tests](#running-tests), and
   [the code style we use in this project](#code-style).
1. Cut a new branch and write a failing test for the feature or bugfix you plan
   on implementing.
1. [Make sure your branch is well managed as you go along](#managing-your-branch).
   API](#documentation).
1. Run your commits through overcommit and ensure all checks pass
1. Push to your fork and submit a pull request.
1. [Ensure that the test suite passes and make any necessary changes to your branch to bring it to green.](#continuous-integration)

We try to respond to contributions in a timely manner. Once we look at your pull
request, we may give you feedback. For instance, we may suggest some changes to
make to your code to fit within the project style or discuss alternate ways of
addressing the issue in question. Assuming we're happy with everything, we'll
then bring your changes into master. Now you're a contributor!

---

## Setting up your environment

The setup script will install all dependencies necessary for working on the
project:

```bash
bin/setup
```

## Architecture

This project follows the typical structure for a Rails application: generally,
application code is located in `app` and tests are in `spec`. Other locations of
interest include:

- `app/frontend` - our webpacker directory (we don't have app/assets)
- `lib` - some additional files that are tangentially related to the application

There are other files in the project, of course, but these are likely the ones
you'll be most interested in.

This application uses service objects, presenters, and other base Ruby objects
where appropriate. We aim to keep classes as single-responsibility as we can.

### Tests

In addition, tests are broken up into two categories:

- Unit tests — low-level tests for individual classes. These tests typically
  stub out arguments and dependencies that an object has.
- Integration tests — high-level tests to ensure that the application works. We
  don't have many of these tests, as we just use them to fill in gaps between
  system and unit tests (for example, API-only controllers).
- System tests - behaviour-driven tests, driven by Capybara through either
  Rack::Test or Google Chrome. Only use Chrome if you absolutely need it, as
  it's the slowest type of test we have.

Our approach to testing tends to iterate over time. The best approach for
writing tests is to copy an existing test in the same file as where you want to
add a new test. We may suggest changes to bring the tests in line with our
current approach.

## Code style

We follow a derivative of the [unofficial Ruby style guide] created by the Rubocop
developers. You can view our Rubocop configuration [here], but here are some key
differences:

- We allow longer blocks in spec files. This is because `RSpec.describe` blocks
  can quite easily go over the default Rubocop limit.
- We have increased the maximum line length to 100 characters.

[unofficial ruby style guide]: https://github.com/rubocop-hq/ruby-style-guide
[here]: .rubocop.yml

We also follow the core ESLint and SASS-Lint style guides, and these processes
are all run as part of the CI process. We use a tool called
[overcommit](https://github.com/sds/overcommit) that will also run a limited set
of core linters each time you commit. This is useful as it helps prevent broken
or incompatibly- styled code from being committed in the first place. If you
have code that you are still working on and just need a savepoint, you can
[skip hooks](https://github.com/sds/overcommit#skipping-hooks), and rebase later
to fix up the failures.

The overcommit configuration can be found in `.overcommit.yml`, and the tool can
be installed by following the
[installation instructions](https://github.com/sds/overcommit#installation).

## Running tests

### Unit tests

Unit tests are typically written for models, presenters, services and other
normal Ruby objects. They can be run with RSpec:

```
bundle exec rspec spec/models spec/services spec/helpers spec/presenters
```

### Integration tests

The integration tests exercise how different parts of the application work
together, usually by making an HTTP request and then asserting against the
response.

To run an integration test, you might say something like:

```bash
bundle exec rspec spec/controllers spec/requests
```

### System tests

The integration tests exercise the behaviour of the application by driving a web
browser and asserting against what happens on the page. System tests are useful
because we can test all of the layers of our application for a particular
behaviour with a single test, but they are also much slower to write, run, and
tend to require more maintenance.

To run a system test, you might say something like:

```bash
bundle exec rspec spec/system
```

### All tests

In order to run all of the tests, simply run:

```bash
bundle exec rake
```

## Managing your branch

- Use well-crafted commit messages, providing context if possible.
- Squash "WIP" commits and remove merge commits by rebasing your branch against
  `master`. We try to keep our commit history as clean as possible.

## Documentation

As you navigate the codebase, you may notice certain classes and methods that
are prefaced with inline documentation.

If your changes end up extending or updating the API, it helps greatly to update
the docs at the same time for future developers and other readers of the source
code.

## Continuous integration

While running `bundle exec rake` is a great way to check your work, this command
will only run your tests against the latest supported Ruby and Rails version.
Ultimately, though, you'll want to ensure that your changes work in all possible
environments. We make use of
[Github Actions](https://github.com/ackama/nzsl-share/actions) to do this work
for us. Actions will kick in after you push up a branch or open a PR. It takes
about 20 minutes to run a complete build.

What happens if the build fails in some way? Don't fear! Click on a failed job
and scroll through its output to determine the cause of the failure. You'll want
to make changes to your branch and push them up until the entire build is green.
It may take a bit of time, but overall it is worth it and it helps us immensely!
