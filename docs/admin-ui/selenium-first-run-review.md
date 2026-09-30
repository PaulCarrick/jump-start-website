# First Selenium run review

82 scenarios ran: 34 passed and 48 failed. This is the original run, before test corrections.

Corrected test setup: Bootstrap CSS build after esbuild; relative record links; numeric order field IDs; keyboard replacement of controlled React inputs; default configuration validation wording; excluding Clear Sort from sort-column discovery; relative pagination links.

The corrected tests have not completed a new browser run. Unresolved editor and persistence assertions remain active. Rerun from `/Users/paul/src/jump-start-website` with `bin/admin-ui-e2e`.

## Original failures

- Admin Selenium UI authentication redirects the gear link to login and signs in with Remember me
- Admin Selenium UI navigation and empty listings expands and collapses the narrow-screen navigation
- Admin Selenium UI Site Setups creates, views, edits, cancels and deletes a configuration
- Admin Selenium UI Site Setups blocks incomplete required fields and a second default configuration
- Admin Selenium UI Users creates, views, updates without changing password, cancels and deletes
- Admin Selenium UI Users persists the Regular access option
- Admin Selenium UI Users persists the Administrator access option
- Admin Selenium UI Users persists the Read Only access option
- Admin Selenium UI Users persists the Post Blogs access option
- Admin Selenium UI Users persists the Super User access option
- Admin Selenium UI Menu Item creates parent and child links, views, edits, cancels and deletes
- Admin Selenium UI Menu Item validates label and numeric order and cancels New without saving
- Admin Selenium UI Footer Item creates parent and child links, views, edits, cancels and deletes
- Admin Selenium UI Footer Item validates label and numeric order and cancels New without saving
- Admin Selenium UI Blogs creates, views, edits visibility/type, cancels and deletes
- Admin Selenium UI Blogs round trips HTML mode and persists rich text formatting
- Admin Selenium UI Blogs searches q_author_cont, returns no results, and clears the search
- Admin Selenium UI Blogs searches q_title_cont, returns no results, and clears the search
- Admin Selenium UI Blogs searches q_content_cont, returns no results, and clears the search
- Admin Selenium UI Blogs searches q_posted_date_eq, returns no results, and clears the search
- Admin Selenium UI Image Files uploads, previews, edits caption/description/group/order, cancels and deletes
- Admin Selenium UI Image Files selects an existing group in the form and updates group through the list prompt
- Admin Selenium UI Image Files validates upload and name, and round trips HTML mode
- Admin Selenium UI Image Files filters images by q_name_cont and clears search
- Admin Selenium UI Image Files filters images by q_group_cont and clears search
- Admin Selenium UI Image Files filters images by q_caption_cont and clears search
- Admin Selenium UI Image Files filters images by q_description_cont and clears search
- Admin Selenium UI Pages, Sections and Cells creates content through New Page, views, edits, cancels and deletes the page
- Admin Selenium UI Pages, Sections and Cells opens Add Section, generates columns and cancels its temporary record
- Admin Selenium UI Pages, Sections and Cells generates the Text Only column template and saves it
- Admin Selenium UI Pages, Sections and Cells generates the Image Only column template and saves it
- Admin Selenium UI Pages, Sections and Cells generates the Dual Column - Text Left column template and saves it
- Admin Selenium UI Pages, Sections and Cells generates the Dual Column - Text Right column template and saves it
- Admin Selenium UI Pages, Sections and Cells generates the Three Column column template and saves it
- Admin Selenium UI Pages, Sections and Cells generates the Four Column column template and saves it
- Admin Selenium UI Pages, Sections and Cells generates the Five Column column template and saves it
- Admin Selenium UI Pages, Sections and Cells views, edits, cancels and deletes Sections and Cells from their lists
- Admin Selenium UI Pages, Sections and Cells round trips Column HTML and formatting modes and persists margins and background
- Admin Selenium UI additional editor and persistence controls persists Column name, order, link and content and leaves canceled edits unchanged
- Admin Selenium UI additional editor and persistence controls switches the Column image picker to Images
- Admin Selenium UI additional editor and persistence controls switches the Column image picker to Groups
- Admin Selenium UI additional editor and persistence controls switches the Column image picker to Videos
- Admin Selenium UI additional editor and persistence controls adds the new page to a header menu and footer through their checkbox controls
- Admin Selenium UI additional editor and persistence controls opens and cancels section and column editors from the Page preview
- Admin Selenium UI additional editor and persistence controls confirms Delete Section and Delete Column in the Page preview
- Admin Selenium UI additional editor and persistence controls paginates Image Files across four-item pages
- Admin Selenium UI sort controls exercises every sort column and Clear Sort in Sections
- Admin Selenium UI sort controls exercises every sort column and Clear Sort in Cells
