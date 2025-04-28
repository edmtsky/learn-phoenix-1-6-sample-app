## Esbuild: a module bundler

- https://esbuild.github.io/
- https://esbuild.github.io/getting-started/

In the Phoenix, `esbuild` is used as a JavaScript bundler and minifier.
Esbuild is a fast and efficient tool that helps manage and optimize front-end
assets in web applications.
Here are some of the specific uses of esbuild in the Phoenix framework:

1. **JavaScript Bundling**:
Esbuild compiles and bundles JavaScript files, which allows developers to
organize their code better and reduce the number of HTTP requests by combining
multiple files into a single bundle.

2. **Minification**:
It reduces the size of JavaScript files by removing whitespace, comments, and
other unnecessary characters, which improves loading times for web applications.

3. **Support for Modern JavaScript**:
Esbuild supports modern JavaScript (like ES6+), which allows developers to use
the latest language features while ensuring compatibility with older browsers
through transpilation.

4. **CSS Processing**:
While esbuild is primarily a JavaScript bundler, it can also handle CSS files,
enabling developers to bundle and optimize their stylesheets along with JavaScript.

5. **Hot Module Replacement (HMR)**:
When integrated with development tools, esbuild allows for real-time updates to
assets in development mode without requiring a full page reload, enhancing
the development experience.

6. **Integration with Phoenix**: In newer versions of Phoenix (specifically
from version 1.6 onwards), esbuild is integrated into the asset management
pipeline, providing a straightforward setup for developers to build and manage
their front-end assets alongside their Elixir back-end.

Overall, esbuild contributes to the speed and efficiency of the asset building
process in Phoenix applications, aligning well with the framework's emphasis on
performance and developer experience.


> briefly:
`esbuilder` - is a bundler for js, css, scss files,
it bundles assets that are optimized to load faster in a production application.


> directory structure in phoenix app:

- `assets/` - compilable assets which are managed by `esbuild`
  has a subdirectory for each asset class:
  - `css`: Cascading Style Sheets
  - `js`: JavaScript

- `priv/static/assets` - directory for compiled files

- `priv/static/` - directory, where you should place your other static content
(no compilation-needed assets).

- `priv/static/images/` - directory created by default (by phx.new) for images
  (e.g. phoenix.png)


what why custom css file goes in `assets/css/` directory


file `build.js` in assets directory is a `esbuild` configuration file, which
configure how to bundle all your CSS and JavaScript files into only two files
what loaded in layout file `app.html.heex` via:


```heex
<script type="text/javascript"
  src={ Routes.static_path(@conn, "/assets/app.js")}></script>
```

> assets/build.js
```js
// ...
let opts = {
  entryPoints: ['js/app.js'],
  bundle: true,
  target: 'es2016',
  outdir: '../priv/static/assets',
  logLevel: 'info',
  loader,
  plugins
}
// ...
```

- the `entryPoints` tells `esbuild` where the starting point is.
- the `outdir` tells `esbuild` where and how to store the resulting files.

In this case, it says to put all JavaScript code found in `assets/js/app.js`
into the file `priv/static/js/app.js`,
the JavaScript that is loaded in your layout file `app.html.heex`.

