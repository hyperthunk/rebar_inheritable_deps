# Rebar Inheritable Deps

This plugin is **very** simple - it keeps track of declared dependencies and if
they are re-declared later on (i.e., in a sub_dir or somewhere further down the
dependency hierarchy) then it strips these out and replaces them with the
original declaration.

If you have a parent rebar config thus:

```erlang
%% parent rebar.config
{deps, [
    %% choose another version of mochiweb
    {mochiweb, "2.4.0",
     {git, "https://github.com/mochi/mochiweb.git"}},
    {webmachine, ".*", %% dangerous game! :D
     {git, "https://github.com/basho/webmachine.git"}}
]}.
```

And the *child* rebar.config (i.e., the config for webmachine) declares some
other version of mochiweb as its dependency like so:

```erlang
{deps, [
        {mochiweb, "1.5.1", {git, "git://github.com/basho/mochiweb",
                            {tag, "1.5.1-riak-1.0.x-fixes"}}}
        ]}.
```

The specified version *1.5.1* of mochiweb will be **ignored** and instead the
version *2.4.0* that you supplied at the top level will be installed. See the
[example](https://github.com/hyperthunk/rebar_inheritable_deps/tree/master/example)
directory for a demonstration of this.

To make this plugin work, you will either need to ensure it is on the code
path (by installing into `ERL_LIBS` or making it a dependency itself) *or*
use your `plugin_dir` rebar configuration to point to it.

```erlang
%% you might want to set - {plugin_dir, "deps/rebar_inheritable_deps_/src"}.
{plugins, [rebar_inheritable_deps]}.
```

## Status

This plugin is **alpha** quality - it has not been extensively tested and should
be considered largely experimental.

## License

The contents of this repository are licensed under a permissive, BSD-3 style
license. See the LICENSE file for details. All rights reserved.
