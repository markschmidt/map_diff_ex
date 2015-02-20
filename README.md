MapDiffEx
=========

MapDiffEx is a tiny Elixir library to perform a deep comparison between Maps. It returns a map where differences between the given maps are expressed as tuple:

```elixir
Interactive Elixir (1.0.0) - press Ctrl+C to exit (type h() ENTER for help)
iex(1)> MapDiffEx.diff(%{a: 1, b: "hello"}, %{a: 2, x: [1,2]})
%{a: {1, 2}, b: {"hello", :key_not_set}, x: {:key_not_set, [1, 2]}}
```


License
--------

This program is free software. It comes without any warranty, to
the extent permitted by applicable law. You can redistribute it
and/or modify it under the terms of the Do What The Fuck You Want
To Public License, Version 2, as published by Sam Hocevar. See
http://sam.zoy.org/wtfpl/COPYING for more details.
