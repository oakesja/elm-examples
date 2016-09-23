# elm-navigation example

Compile with `build.sh` and then open the index.html file to see the example running.

This shows off how to use elm's navigation package to create a single page application. The idea behind this package is that it wraps your existing/new elm application and allows you to update your model based off of the browser's current location. It provides similar interfaces that `Html.App` programs but includes the following extra things:

- a parser to parse the new `Location` into something
- a function to take the parsed thing and update your model accordingly
- the init also takes the parsed thing so you can init your model appropriately

Otherwise msgs, updates, models, and subscriptions work the same.

The example uses very simple url parsing since there are only 3 pages. For fancier url parsing, especially when paths include variables, check out [evancz/url-parser](https://github.com/evancz/url-parser)

The package also includes functions to update the current location as well as going forward and backward in the browser history.

Overall I was pleasantly surprised how easy it was to set up and get working. After doing just this example, it became clear to me that for most apps the parser should be parsing pages from the location where a page is a union type. The current page should be stored in the model, so the correct view function can be displayed.
