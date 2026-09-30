# Third Selenium run review

82 scenarios completed in 350 seconds: **52 passed, 30 failed**, zero pending cases and zero suite-level errors. The previous run had 53 passes and 29 failures. There is no verified improvement in this run.

Results: `/Users/paul/src/jump-start-website/tmp/admin-ui-e2e/20260930-081029-6801/results.json`.

## Remaining test corrections

The previous custom fill_in helper was shadowed by Capybara::DSL, so two existing-field edits still appended values. It is now explicitly named fill_field at all call sites. Three Column image-mode tests now select by actual option values (Images/Groups/Videos); their visible labels are Image/Image Group/Video. The mobile screenshot confirms a visible hamburger at the requested narrow width; its test now finds the aria-label attribute directly because Capybara button matching did not resolve it. These changes passed Ruby syntax checks but have not been verified in a browser rerun.

## Application failures and reproduction candidates

- Entered blog body is rejected as blank, blocking CRUD and four searches.
- Blog/image HTML mode does not open a textarea.
- All seven section templates render columns, but Save remains on the editor; Cancel does too. View prop names successPath/cancelPath differ from editor options.returnUrl/options.cancelUrl.
- Column margins fail to survive reopening Edit.
- Invalid-login feedback is not visible.
- Image Add to Group fails to expose a populated dropdown.
- Image description editor is absent during Edit and description search finds no matching record.
- Nested column Cancel renders a generic error.
- Delete Column does not open the expected confirmation.
- Public linked-page title stays UI Test Site.
- A detached-document Chrome inspector error moved between search scenarios, suggesting browser/driver instability or navigation timing; attribution requires reproduction.

Thirty failures are not thirty independent application bugs. Several depend on the same broken setup flow, and some remain test/driver issues. No application changes, commits or pushes were made in this review. The next useful work is fixing the reproducible application defects, then running affected cases and finally the whole suite.

## Original failed scenarios

- Admin Selenium UI authentication redirects the gear link to login and signs in with Remember me
- Admin Selenium UI navigation and empty listings expands and collapses the narrow-screen navigation
- Admin Selenium UI Site Setups creates, views, edits, cancels and deletes a configuration
- Admin Selenium UI Users creates, views, updates without changing password, cancels and deletes
- Admin Selenium UI Blogs creates, views, edits visibility/type, cancels and deletes
- Admin Selenium UI Blogs round trips HTML mode and persists rich text formatting
- Admin Selenium UI Blogs searches q_author_cont, returns no results, and clears the search
- Admin Selenium UI Blogs searches q_title_cont, returns no results, and clears the search
- Admin Selenium UI Blogs searches q_content_cont, returns no results, and clears the search
- Admin Selenium UI Blogs searches q_posted_date_eq, returns no results, and clears the search
- Admin Selenium UI Image Files uploads, previews, edits caption/description/group/order, cancels and deletes
- Admin Selenium UI Image Files selects an existing group in the form and updates group through the list prompt
- Admin Selenium UI Image Files validates upload and name, and round trips HTML mode
- Admin Selenium UI Image Files filters images by q_group_cont and clears search
- Admin Selenium UI Image Files filters images by q_description_cont and clears search
- Admin Selenium UI Pages, Sections and Cells opens Add Section, generates columns and cancels its temporary record
- Admin Selenium UI Pages, Sections and Cells generates the Text Only column template and saves it
- Admin Selenium UI Pages, Sections and Cells generates the Image Only column template and saves it
- Admin Selenium UI Pages, Sections and Cells generates the Dual Column - Text Left column template and saves it
- Admin Selenium UI Pages, Sections and Cells generates the Dual Column - Text Right column template and saves it
- Admin Selenium UI Pages, Sections and Cells generates the Three Column column template and saves it
- Admin Selenium UI Pages, Sections and Cells generates the Four Column column template and saves it
- Admin Selenium UI Pages, Sections and Cells generates the Five Column column template and saves it
- Admin Selenium UI Pages, Sections and Cells round trips Column HTML and formatting modes and persists margins and background
- Admin Selenium UI additional editor and persistence controls switches the Column image picker to Images
- Admin Selenium UI additional editor and persistence controls switches the Column image picker to Groups
- Admin Selenium UI additional editor and persistence controls switches the Column image picker to Videos
- Admin Selenium UI additional editor and persistence controls adds the new page to a header menu and footer through their checkbox controls
- Admin Selenium UI additional editor and persistence controls opens and cancels section and column editors from the Page preview
- Admin Selenium UI additional editor and persistence controls confirms Delete Section and Delete Column in the Page preview
