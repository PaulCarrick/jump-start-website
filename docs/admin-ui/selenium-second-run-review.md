# Second Selenium run review

82 browser scenarios completed in 305 seconds: **53 passed, 29 failed**, no pending cases or suite errors. The first run had 34 passes and 48 failures.

Results: `/Users/paul/src/jump-start-website/tmp/admin-ui-e2e/20260930-075014-3979/results.json`. Failure PNG, HTML and text files sit alongside it.

## Test corrections after this run

- Existing-field edits now use keyboard replacement rather than Selenium's default selection, which appended text on this machine.
- Column image mode uses a supported select matcher.
- Upload required-state assertion accepts Selenium's false boolean representation.
- Numeric input replacement compares numeric values to allow React's leading-zero normalization.
- Mobile failure screenshots are captured before restoring desktop dimensions.

Ruby syntax checks pass. These latest corrections have not been verified by a new browser run. No application changes, commits or pushes were made in this review.

## Application evidence to investigate

- Blog creation rejects entered rich text as blank content, blocking five other blog scenarios. The HTML callback builds a Function parameter from the editor ID; hyphenated IDs are invalid parameter names.
- Blog and image HTML switches do not expose a textarea.
- Section Save/Cancel remain on the section editor in eight scenarios. Rails `_section_form.erb` passes successPath/cancelPath while `SectionEditor.tsx` reads options.returnUrl/options.cancelUrl.
- Column margins fail to persist after reopening.
- Invalid-login feedback is absent from visible text.
- Add to Group has an empty, hidden dropdown after clicking.
- Canceling the nested column editor renders a generic error page.
- Delete Column has no confirm dialog; its React anchor uses data-confirm, which needs a working confirmation handler.
- Mobile toggler was not found at the requested window size. The previous screenshot was captured after resizing back; the test now captures the narrow layout first so the next run can distinguish browser sizing from application behavior.
- One image-search failure was a Chrome detached-document inspector error, requiring reproduction before attribution.

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
