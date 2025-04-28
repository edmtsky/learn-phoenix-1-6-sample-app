# SASS - Syntactically Awesome StyleSheets

- https://sass-lang.com/

  Sass Color variabled defined in Bootstrap:
- https://getbootstrap.com/docs/4.3/getting-started/theming/#available-variables


## Theory of SASS

SASS (Syntactically Awesome Style Sheets) is a preprocessor scripting language
that is interpreted or compiled into Cascading Style Sheets (CSS). It allows
developers to use features like variables, nested rules, mixins, and functions,
which help in writing more maintainable and scalable CSS. SASS makes it easier
to organize stylesheets, promote reuse, and provide advanced functionality that
standard CSS does not support.


### Key Features of SASS:

1. **Variables:**
   Store values like colors or fonts that can be reused throughout your stylesheets.

2. **Nesting:**
   Organize your CSS in a hierarchical structure, which reflects the HTML structure.

3. **Partials and Imports:**
   Break down stylesheets into smaller, manageable pieces and
   combine them into one larger stylesheet.

4. **Mixins:**
   Create reusable sets of styles that can be included in different selectors,
   optionally taking arguments.

5. **Functions:**
   Use built-in or custom functions for more complex styles.

6. **Inheritance:**
   Share properties between selectors (using extend).


### Using SASS in the Phoenix Framework:

Phoenix is a web framework built on the Elixir programming language, which
utilizes the MVC architecture. Phoenix integrates well with front-end
technologies, including SASS.

1. **Integration:**
   Phoenix supports SASS through its asset management tool,
   typically using esbuild (or the built-in asset pipeline).

2. **Installation:**
   Usually, you can add SASS to a Phoenix project by including the appropriate
   package in your asset dependencies (for example, using npm or yarn) and
   setting up a configuration file.

   **Example using npm:**
   ```bash
   npm install sass --save-dev
   ```

3. **Setup:**
   Once SASS is installed, you would typically configure your build tool
   (like esbuild) to compile `.scss` files into CSS.
   In your `build.js`, you would set up a rule to process SASS files.

4. **File Structure:**
   You can create a directory structure for your SASS files, often placing them
   under the `assets/css` directory if using the default Phoenix structure.

5. **Compilation:**
   When you run your Phoenix server and build your assets, the SASS files will
   be compiled into standard CSS files, which are then referenced in your HTML
   templates.

6. **Using SASS Features:**
   You can start using SASS features in your stylesheets, such as
   creating variables for your theme colors or nesting styles to match your
   HTML structure.

### Example:

Here’s a simple example of a SASS file (`styles.scss`):

```scss
$primary-color: #3498db;

body {
  background-color: $primary-color;

  h1 {
    color: white;
  }

  .container {
    padding: 20px;

    .button {
      background-color: darken($primary-color, 10%);
      color: white;
    }
  }
}
```

When you compile this SASS file, it converts to regular CSS which
the browser can understand.

### Conclusion:

Using SASS within the Phoenix framework enhances the styling process, providing
powerful tools that simplify CSS management. By leveraging the features of SASS,
developers can create organized, efficient, and maintainable style sheets for
their Phoenix applications.



## The most important thing is where we start using SASS with examples

`Sass` is a language for writing stylesheets that improves on CSS in many ways.
Two of the most important improvements is nesting and variables.

`Sass` supports a format called `SCSS`
(indicated with a `.scss` filename extension),
which is a strict superset of `CSS` itself.

SCSS only adds features to `CSS`, rather than defining an entirely new syntax.
This means that every valid `CSS` file is also a valid `SCSS` file,
which is convenient for projects with existing style rules.

In my case, I used SCSS from the start in order to take advantage of Bootstrap.

Since you set up `esbuild` to use `Sass` to process files with the `.scss`
extension, the `custom.scss` file will be run through the `Sass` preprocessor
before being packaged up for delivery to the browser.


### Nesting

A common pattern in stylesheets is having rules that apply to nested elements.
For example, here we have rules both for `.center` and for `.center` `h1`:

```css
.center {                    /* <<< */
  text-align: center;
}

.center h1 {                 /* <<< */
  margin-bottom: 10px;
}
```

We can replace this in `Sass` with:
```scss
.center {                    /* <<< */
  text-align: center;
  h1 {                       /* <<< */
    margin-bottom: 10px;
  }
}
```

Here the nested `h1` rule automatically inherits the `.center` context.

There's a second candidate for nesting that requires a slightly different syntax.

```css
#logo {                         /* <<< */
  float: left;
  margin-right: 10px;
  font-size: 1.7em;
  color: #fff;
  text-transform: uppercase;
  letter-spacing: -1px;
  padding-top: 9px;
  font-weight: bold;
}

#logo:hover {                   /* <<< */
  color: #fff;
  text-decoration: none;
}
```

to nest the second rule(attribute hover), you need to reference the parent
element `#logo`.
In `SCSS`, this is accomplished with the `&` as follows:

```scss
#logo {                         /* <<< */
  float: left;
  margin-right: 10px;
  font-size: 1.7em;
  color: #fff;
  text-transform: uppercase;
  letter-spacing: -1px;
  padding-top: 9px;
  font-weight: bold;
  &:hover {                     /* <<< */
/*^*/
    color: #fff;
    text-decoration: none;
  }
}
```

Sass changes `&:hover` into `#logo:hover` as part of converting from SCSS to CSS.


```css
/* footer */

footer {
  margin-top: 25px;
  padding-top: 15px;
  border-top: 1px solid #eaeaea;
  color: #343a40;
}

footer a {
  color: #555;
}

footer a:hover {
  color: #222;
}

footer small {
  float: left;
}

footer ul {
  float: right;
  list-style: none;
}

footer ul li {
  float: left;
  margin-left: 15px;
}
```

can be converted to:
```scss
footer {
  margin-top: 25px;
  padding-top: 5px;
  border-top: 1px solid #eaeaea;
  color: #343a40;
  a {
    color: #555;
    &:hover {
      color: #222;
    }
  }
  small {
    float: left;
  }
  ul {
    float: right;
    list-style: none;
    li {
      float: left;
      margin-left: 15px;
    }
  }
}
```



### Variables

Sass allows us to define variables to eliminate duplication and
write more expressive code.

```css
h2 {
  /* ... */
  color: #343a40;
/*        ^^^^^^ */
}
/*...*/

footer {
  /* ... */
  color: #343a40;
/*        ^^^^^^ */
}
```

In this case, `#343a40` is a dark gray, and you can give it a name
by defining a variable as follows:

```scss
$dark-gray: #343a40;
```

This allows you to rewrite your SCSS like this:

```scss
$dark-gray: #343a40;
/* ... */

h2 {
  /* ... */
  color: $dark-gray;
}
/* ... */

footer {
  /* ... */
  color: $dark-gray;
}
```

Bootstrap framework defines a large number of variables for colors,
available online on the [Bootstrap page of Sass variables][5].

And there you can find such a variable:
```sh
$dark: #343a40;
```

So, you can use this variable to replace our custom variable, `$dark-gray`:

```scss
h2 {
  /* ... */
  color: $dark;
}
  /* ... */
footer {
  /* ... */
  color: $dark;
}
```


SASS also has built-in named colors (i.e., `white` for `#fff)`.
