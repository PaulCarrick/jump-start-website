# Admin redesign plan

Mockups: https://claude.ai/artifact/9oLNPKThDN5cGt2abThEPt (private to the owner; seven screens).

## Goal and limits

- Make the admin cleaner and easier to use. **Only the admin changes**: the public site's look, pages and addresses stay exactly as they are.
- Keep every feature the admin has today. Where a screen is replaced, the old address keeps working (redirect or the same route) until the new screen has proved itself.
- Keep the models, the draft-and-publish system and the JSON API. Most of the work is new layouts and views over the existing controllers; back-end changes are listed where a stage needs them.
- Ship in stages. Each stage is deployable on its own, has its own tests, and leaves the admin fully usable.

## What changes, at a glance

| Today | Proposed |
|---|---|
| Admin inside the public header, footer and blue background | Its own frame: slim top bar (site name, search, View site, Publish with a count, account) and a grouped sidebar |
| Sidebar built from "Admin" menu items in the database: Site Setups, Users, Menu Items, Footer Items, Pages, Sections, Columns, Image Files, Blogs, Deploy Changes, Help, New Site Tutorial | Fixed sidebar in code: Dashboard · Content: Pages, Blog, Media · Site: Menus, Settings, Users · Help and tutorial |
| "Draft workspace" banner on every screen | The Publish button's count, and a status on each item |
| Tall list rows with View / Edit / Delete buttons, sort buttons | Compact tables: search, sortable headings, status badge, click the title to edit, rare actions in a ⋯ menu |
| Sections and Columns as their own lists and editors | Edited inside their page (the lists stay reachable by address for power use) |
| Page edit: a 4,000 px scroll with five buttons on every block; column edit on a separate long form | One screen: outline (drag to reorder), live preview (click to select), side panel with tabs Content · Image · Layout · Advanced |
| Menu Items and Footer Items as two lists | One Menus screen: header and footer trees, drag to reorder or nest, a small settings panel |
| Image Files: 50 pages of full-size previews | Media library: thumbnail grid, group filters, drag-and-drop upload, details panel with "Used on" |
| Site Setup: one 3,200 px form | Settings with tabs: General · Email (with "Send a test email") · Appearance · Social links · Advanced |
| Deploy Changes: "Column 62 v4 Update", 30 bare timestamps | Review and publish: plain-language changes with before/after, confirm, readable history |

## Feature checklist: everything the admin does today, and where it goes

Nothing on this list is dropped. "Same" means the feature keeps working as it does now, inside the new layout.

**Pages, sections and columns**
- Pages: create, edit name / section / title / access / enabled, delete, view, history → Pages list and the page editor's Page settings.
- Sections: add (with the layout templates Text Only, Image Only, Dual Column Text Left / Right, Three / Four / Five Column), edit, duplicate (single or a whole section group), delete, renumber, section group, order, enabled → the page editor's outline and side panel.
- Columns: content, image, link, order, enabled, delete, edit → the side panel.
- **HTML editing**: the editor's "Switch to HTML View" (raw HTML) stays, in the side panel's Content tab and everywhere `HtmlEditor` is used (blog posts, image captions and descriptions).
- **Formatting**: margins (top, left, bottom, right), background color, image classes and styles, caption classes and position, container classes, expanding rows and columns, div ratio, and "Switch to Formatting Mode" (raw CSS classes and styles) → the Layout tab (pickers) and the Advanced tab (raw CSS), same fields and same stored values.
- **Colors**: chosen from a **palette** of swatches (the named colors in `backgroundColors.jsx`, plus the site's own colors) instead of a long drop-down; a custom value stays possible under Advanced. Site Setup's header, footer and page colors use the same palette.
- Images in columns: image picker, "New Image" from inside the editor, image groups and slide shows (prompt type), image sections, videos → the Image tab.
- Live preview and "Preview draft" → the page editor's preview and Preview button.

**Other content**
- Blog posts: title, author, type (Personal / Professional), visibility, posted date, content (with HTML view), enabled, search, sort → Blog list and editor.
- Image files: upload, name, caption, description (with HTML view), group and Add Group, mime type, replace, delete, search, sort, pagination → Media library.
- Menu and footer items: type, label, icon, options, link, access, order, parent, enabled → Menus screen.

**Site, people and publishing**
- Site Setups: every field on today's form (identity, database, URL, guest user, mail server, contact email, colors, background image, social links, copyright, default), several setups for several sites, new setup with name suggestions, database retry → Settings tabs (and a setups list where there is more than one).
- Users: email, name, password, access level, roles, approved, enabled → Users list and form.
- Drafts and publishing: deploy with a summary, discard all, review draft values, preview draft, history and "restore as draft", database sync retry → Review and publish, History on each item.
- Search, sorting and paging on every list; keyboard shortcuts (Save, New, Cancel, paging); Help and the New Site Tutorial; read-only users can look but not change; secondary sites hide Site Setups → kept.

## Decisions made in this plan (say if you want them otherwise)

1. **The admin sidebar moves into code.** It stops reading the "Admin" menu items from the database. Those records stay (nothing is deleted, and new sites still get them), they simply stop being shown. A fixed sidebar is what makes the grouping and the permissions predictable.
2. **Saving stays explicit at first.** Editors keep a Save button, now in a fixed place, and say "Saved as draft". Autosave can come later.
3. **Old screens stay reachable during the transition** (by address, and a "Classic editor" link on the new page editor) until the new one has been used for real.
4. **Selective publishing is by page, not by record.** A new section and its columns must go live together, so the review screen lets you leave out a page's changes as a whole. Today's all-at-once publish stays as the default.

## Stages

Each stage: build, update the affected tests (system specs and `spec/e2e`), check in the browser at desktop and phone widths, deploy, then update `docs/admin-guide.md` and `docs/new-site-tutorial.md` for that stage.

### Stage 1 · The admin frame (medium)
- New `app/views/layouts/admin.html.erb`, a full layout of its own (no public header or footer), used by `Admin::AbstractAdminController` and the other admin controllers. Replaces `_admin_page.erb` and `_admin_menu.erb`.
- Top bar and sidebar from a small `AdminNavigation` helper (entries, groups, which roles see each: read-only users keep their current view-only access; Site Setups stays hidden on secondary sites as today).
- Publish button with the count of pending changes (`Publishing.pending`); the draft banner goes.
- Admin styles in one stylesheet with a few named colors and sizes (from the mockups), on top of Bootstrap.
- New Dashboard: unpublished changes, site counts, last publish, quick actions, recently edited.
- Tests: sidebar and navigation specs (`admin_help_spec`, `admin_navigation_protection_spec`, `admin_return_navigation_spec`), plus a phone-width check of the sidebar.

### Stage 2 · Lists (medium)
- One shared list partial: title, count, New button, search, filters, sortable headings, status badge (Live, Draft changes, Hidden, New), ⋯ menu with the existing `delete_button`.
- Convert Pages, Blog, Users first, then the rest (Menu Items, Footer Items, Columns, Sections, Image Files until Stage 4 replaces it).
- Status needs one query per list (pending versions by id); add it to the base controller.
- Tests: list specs that look for View / Edit / Delete buttons (about a dozen).

### Stage 3 · Settings tabs and the Menus screen (medium)
- Settings: the existing Site Setup form split into tabs on one page (still one Save). New "Send a test email" action that uses the saved mail settings and reports the result.
- Menus: one screen with header and footer trees. Drag to reorder and nest, saved through one new endpoint that updates `menu_order`/`footer_order` and `parent_id` as drafts. A side panel edits the selected item; "Links to" offers the site's pages, with a free web address as the fallback (the `SafeLink` rules still apply).
- Tests: menu and footer specs, a new spec for reordering.

### Stage 4 · Media library (medium)
- Grid view of image files with group filter chips and search; details panel to edit name, caption, group and replace the file.
- Drag-and-drop upload of several files at once (today: one per form).
- "Used on": find the pages whose sections or columns name the image (`ImageFile:<name>` and image groups).
- Keep the image picker the editors use working (`image_picker` specs).

### Stage 5 · The page editor (large: the biggest stage)
- New React screen `PageWorkspace` built from the existing pieces (`RenderSection`, `RenderCell`, `CellEditor`, `HtmlEditor`):
  - outline of sections and columns; drag to reorder (sections through the existing renumbering, columns by order);
  - live preview; clicking a block selects it, and only the selected block shows Duplicate / Delete;
  - side panel editing the selected column, with the current column fields regrouped into tabs Content · Image · Layout · Advanced;
  - Page settings (name, title, access, enabled) in a dialog; Add section from the outline (with the existing layouts: text only, image left, three columns …).
- Saves go through the existing API endpoints (sections, cells) as drafts, as today.
- Keep the current page, section and column editors behind "Classic editor" until this has been used for a while.
- Tests: the page, section and column specs (`admin_pages_spec`, `admin_sections_spec`, `admin_return_navigation_spec`, `duplicate_sections_spec`, `renumber_sections_spec`, `div_ratio_spec`, `image_formatting_spec`, `cell_image_selection_spec`, `quill_two_editing_spec`) move to the new screen; Vitest for the React state.

**Built (2026-11-08):** `/admin/pages/:id/workspace` (`PagesController#workspace`, `reorder`, `add_column`; views `pages/workspace` and its two panel partials; Stimulus `page-outline` and `page-preview`; `CellEditor` with `tabbed: true`). The Pages list, the dashboard and the ⋯ menu ("Classic editor") lead to it. Still through the classic screens, one click away: the section editor (name, order, column widths, the layout chooser for a new section) and the page's Renumber Sections. Columns move only within their own section.

### Stage 6 · Review and publish (medium, with back-end work)
- Plain-language list of pending changes, grouped by page ("Employment History — page title changed"), before/after for changed text fields (from `Publishing.review_attributes`), links to open or preview.
- Publish by page: `Publishing.deploy!` gains an optional list of pages; it publishes those pages' drafts (page, sections, columns, their menu items) and leaves the rest as drafts. Site Setup, users, menus without a page and blog posts form their own groups.
- A confirmation step, and a history that says what each publish contained (store a short summary on `Deployment`).
- Tests: publishing specs, plus new ones for partial publishing (dependent records, conflicts, the advisory lock).

**Built (2026-11-08):** `PublishingReview` groups the drafts (one group per page with its sections, columns and menu and footer entries; then Header menu, Footer, Blog, Media, Settings, Users); `Publishing.deploy!` and `discard!` take `only:`; the review page sends `groups[]` and the `reviewed[]` tokens (class, id, version, saved time) and nothing is published if they no longer match; `deployments.contents` (migration 20261108160000) records what each publish held. Without `groups[]`, publish and discard work on everything, as before.

## Risks and how they are handled

- **Many tests drive the current admin markup** (about 30 system specs and the Selenium e2e run). Each stage updates the specs for the screens it changes, in the same commit.
- **Secondary sites** get their admin navigation copied from the default site today. With the sidebar in code this stops mattering; the provisioner's copying is left alone.
- **Partial publishing touches the draft system's core.** It comes last, behind its own tests, and the all-at-once publish stays available.
- **Phones:** the admin is desktop-first (as now), but every new screen must remain usable at phone width (sidebar collapses, tables scroll).

## Suggested order and size

1 → 2 → 3 → 4 → 5 → 6. Stages 1 and 2 give the biggest visible improvement for the least risk; Stage 5 is about as big as 1 to 4 together.
