# whatr 1.0.0

* Fix player scraping for season 35 multi-team episodes (#7).
* Rename `whatr_info()` to `whatr_airdate()`.
* Remove `whatr_id()` in favor of `whatr_html()`.
* Rename the `n` column to `i` to avoid confusion with `count()`, etc.
* Stop splitting the player `from` column into `city` and `state`.
* Finish documentaing all the functions.
* Use spelling.

# whatr 0.5.0

* Rename `whatr_info()` to `whatr_airdate()`.
* Remove `whatr_id()` in favor of `whatr_html()`.
* Rename the `n` column to `i` to avoid confusion with `count()`, etc.
* Stop splitting the player `from` column into `city` and `state`.
* Finish documenting all the functions.

# whatr 0.4.1

* Use new `entity_clean()` for all `html_text()`.
* Use `html_attr()` for final answer too.

# whatr 0.4.0

* Rename `whatr_summary()` to `whatr_synopsis()`.
* Add data from the 35th season of the show.

# whatr 0.3.0

* Use _new_, new `whatr_html()` method as input for all functions.
* Add `whatr_doubles()`

# whatr 0.2.0

* Use new `whatr_html()` method as optional input for all functions.
* Add `whatr_plot()`.

# whatr 0.1.0

* Add all functions with proper pipe formatting.
  * `whatr_data()`
  * `whatr_info()`
  * `whatr_summary()`
  * `whatr_players()`
  * `whatr_scores()`
  * `whatr_board()`
      * `whatr_categories()`
      * `whatr_clues()`
      * `whatr_answers()`

# whatr 0.0.2

* Added basic functionality for scores.
* Added a `NEWS.md` file to track changes to the package.
* Removed all other functions, need to code as `dplyr` pipes.
