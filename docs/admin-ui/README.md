# Admin UI specification and Selenium verification

The UI audit, screen records, screenshots, and Selenium repair reports are stored here. Application fixes remain in their normal app/ paths; the test runner is bin/admin-ui-e2e, with browser scenarios in spec/e2e and focused editor regressions in spec/javascript.

- [Front-end specification](front-end-spec.md)
- [Screenshot gallery](screen-gallery.html)
- [Screen and interaction records](screen-records.json)
- [Full-suite successful run](selenium-success-20260930-112550.md): 82 passed, zero failures, successful database cleanup.

Run from the repository directory:

```sh
bin/admin-ui-e2e
```

These changes are uncommitted. At verification time, this checkout was on main. The separate checkout /Users/paul/src/updated/jump-start-website is a different directory.
