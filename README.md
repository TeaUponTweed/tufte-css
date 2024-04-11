Tufte CSS
=========

Customization of [tufte-css](https://github.com/edwardtufte/tufte-css) designed to be used with [pandoc](https://pandoc.org) and [normalize.css](https://github.com/necolas/normalize.css). The sidenotes.lua pandoc filter was adapted from [this repo](https://github.com/jez/pandoc-sidenote).

To generate a webpage, run `pandoc <input.md> -o <output.html> --section-divs --embed-resources --standalone --css=tufte.css --css=normalize.css --lua-filter sidenotes.lua --lua-filter link-headers.lua`

I have made the following changes:
- [Footnotes](https://pandoc.org/chunkedhtml-demo/8.19-footnotes.html) are treated as sidenotes unless the line prefixed with `{.}`. For example `^[{.} this is a footnote]` vs `^[this is a sidenote]`.
- Use sans-serif fonts by default. The custom et-book fonts have been removed from the repository
- Section headers are self-links

An example input markdown file can be found [here](./example/example.md) along with the corresponding HTML [preview](https://html-preview.github.io/?url=https://github.com/TeaUponTweed/tufte-css/blob/main/example/example-output.html) and [source](./example/example-output.html).
