# Admin user guide

Use this guide to maintain the website from the admin. It covers editing pages, managing media and menus, changing settings, and publishing. Open **Help** at the bottom of the sidebar to return here.

## Table of contents

- [Getting started](#getting-started)
- [Publishing changes](#publishing-changes)
- [Using list pages](#using-list-pages)
- [Pages, sections, and columns](#pages-sections-and-columns)
- [Pages](#pages)
- [Sections](#sections)
- [Columns](#columns)
- [Writing and formatting content](#writing-and-formatting-content)
- [Image files and groups](#image-files-and-groups)
- [Blogs](#blogs)
- [Menus](#menus)
- [Users and access](#users-and-access)
- [Site setups](#site-setups)
- [Keyboard shortcuts](#keyboard-shortcuts)
- [Common questions](#common-questions)

## Getting started

Sign in with an account that has access to administration. The admin has its own frame:

- The **top bar** shows the site's name, **View site** (opens the public site in a new tab), **Publish** with the number of changes waiting, your name and **Log out**.
- The **sidebar** is grouped: **Dashboard**; **Content** (Pages, Blog, Media); **Site** (Menus, Settings, Users); **Page parts** (Sections, Columns, the classic lists); and **Help** and **New Site Tutorial** at the bottom. On a phone, the ☰ button opens it.
- The **Dashboard** shows what is waiting to be published, the site's counts, the last publish, quick actions and the pages and posts edited most recently.

A typical content change is:

1. Open **Pages** and click the page's title. The page opens in its workspace.
2. Click the section in the preview, or the column in the outline.
3. Change the content in the panel on the right and choose **Save Column**.
4. Choose **Publish** in the top bar, check the change, and publish it.

The **Enabled** switch controls whether a record appears on the public website. New and existing records start enabled. Switch it off and save to hide content without deleting it; it remains visible and editable in admin. Disabling a page hides its sections and columns from that page. Disabled sections hide their columns, and disabled images are excluded from public image lookups and groups. Public navigation and blogs also honor Enabled. The user switch controls the record's enabled status; it does not change the account's access level or password.

Fields marked with an asterisk are required. Some editors keep Save disabled until the necessary data is available. A disabled Save button cannot be activated with its keyboard shortcut.

**Cancel** returns from an editor without saving its current changes. It does not undo changes you have already saved.

## Publishing changes

Admin edits are saved as **drafts**. Visitors keep seeing the live site until you publish. New records and deletions are drafts too. Lists show each record's status: **Live**, **Draft changes**, **New** or **Hidden**.

Choose **Publish** in the top bar (the number is how many changes are waiting) to open **Review and publish**:

1. Changes are **grouped by page**: a page's settings, its sections and columns, and the menu and footer entries that point to it form one group. Changes elsewhere are grouped as Header menu, Footer, Blog, Media, Settings and Users.
2. Each change says what it is (**New**, **Changed**, **Moved** or **Deleted**) and, for a change, shows each field **live now** and **after publishing**. Long texts are shown from just before the first difference.
3. **Open page** opens the page's workspace; **Preview draft** shows the page with its drafts, for administrators only; **Edit** opens the record; **History** lists its versions.
4. Untick a group to leave it as a draft. A group is published or left as a whole, so a page never goes live half-finished.
5. Optionally add a **note for the history**, then choose **Publish** (the button says how many changes). Confirm, and the ticked changes go live together. If anything fails, nothing is published.

If someone saves a change in a ticked group after you opened the page, nothing is published and you are asked to review again. Several administrators share one set of drafts, so coordinate before publishing or discarding.

**Discard selected** deletes the ticked drafts and leaves the live site as it is.

**Published before** lists each publish: when, by whom, what it contained, and its note.

**History** (on a record, or on any edit screen) shows the record's versions. **Restore as Draft** prepares an earlier version as a draft to review and publish. Passwords and secret credentials are never restored. Changing an account's password or access is also a draft until published.

## Using list pages

Lists (Pages, Blog, Users and others) share one layout:

- The heading shows how many items there are and the **New …** button.
- One **search box** searches the main fields (the Blog list has separate Title, Author, Contents and Posted fields). **Clear** removes the search.
- Click a **column heading** to sort by it; click it again to reverse. The arrow shows the current sort. **Clear Sort** returns to the default order.
- Each row has a **status** and an **Edit** button. The **⋯** menu holds **View**, **History** and, for administrators, **Delete** (which asks before deleting). For pages it also holds **Classic editor**.
- **First**, **Previous**, **Next** and **Last** move between pages of results.

Deleting a section also removes its columns. A deletion is a draft until published.

## Pages, sections, and columns

The content structure has three levels:

- A **page** is a website destination with a title, name (its address), access setting, and content.
- A **section** is an ordered block within a page. A section contains one or more columns.
- A **column** contains text, an image, video, or a combination of content and formatting.

A page's **Section** field and a section's **Section group** field serve different purposes. The page field names the set of sections shown on that page. The section field groups neighboring sections so they can be kept together and duplicated as a unit.

## Pages

### The page workspace

Open **Pages** and click a page's title (or **Edit**). The workspace has three parts:

- The **outline** (left) lists the sections and the columns in each. Click a name to edit it.
- The **preview** (middle) shows the page as it will look. Click a section to select it. Links in the preview do not navigate away.
- The **panel** (right) edits what you selected.

**Reordering:** use **↑** and **↓** in the outline, or drag the **⠿** handle. Sections move within the page; columns move within their section. The new order is saved as a draft at once and the preview updates.

**A column** opens in the panel with four tabs:

- **Content**: the text (with **Switch to HTML View**) and the column's link.
- **Image**: the picture, image group, slide show or video, and **New Image**.
- **Layout**: the formatting fields (margins, background, image and caption classes and styles, and the rest).
- **Advanced**: Enabled, the column's name and its order.

An image column opens on the Image tab. A small preview of the column sits under the tabs; the page preview updates when you choose **Save Column**. **Delete this column** removes it.

**A section** shows its **Section group** and Enabled switch (**Save section**), its columns, **+ Add column** (an empty text column at the end), **Edit section layout** (the classic section editor, for the section's name, order and column widths), **Duplicate section** or **Duplicate group** (asks for the new name), and **Delete section**.

**Page settings** (top of the workspace) edits the title, the name, access, the Section field and Enabled. Changing the name changes the page's address; update menu links to match.

**+ Add section** (under the outline) opens the layout chooser: Text Only, Image Only, dual-column text and image arrangements, and layouts with several columns. Choose a layout, fill in what it asks for, choose **Generate Columns**, then **Save Section**. Cancel removes the new, empty section. Either way you return to the workspace.

**View page** opens the live page; **Classic editor** opens the previous page editor, which is kept while the workspace is new.

### Editing from the page itself

Signed in as an administrator, every page of the site has **Edit Page** at the bottom. Choosing it puts the page in editing mode: the page shows your drafts, and the button becomes **Editing… Save Changes** with **Cancel** beside it.

Right-click the page and choose **Edit** to open the matching editor in a new tab:

- on a **picture**: the media library with that picture selected;
- on a **column's** text or the space beside it: that column in the page workspace;
- on the **space above or below a section's content**: that section in the page workspace;
- anywhere else, such as **beside the buttons**: the page workspace.

Coming back to the page's tab shows what you saved. **Save Changes** publishes the changes made since you chose Edit Page, and **Cancel** discards them (it asks first). Changes made before you started, by you or by others, are left alone; the bar says when some are waiting, with a link to Review and publish. Shift + right-click still gives the browser's own menu.

Links to the admin in the site's header and footer open it in a new tab.

### Creating a page

1. Open **Pages**, then **New page**.
2. Enter the Page Title and a unique Page Name. The name is the page's address, so choose it deliberately.
3. Enter the Section field. Fill in Access if needed.
4. Save the page, then open it from the Pages list and use **+ Add section**.
5. Add the page to the header menu or footer on the **Menus** screen if visitors should find it there.
6. Publish the page with its sections and columns.

### Section ordering

Sections have numeric order values; reordering in the outline sets them to 10, 20, 30 and so on. The classic editor's **Renumber Sections** does the same for the whole page. Grouped sections stay together when duplicated.

## Sections

Sections are normally edited from the page workspace. The **Sections** list under Page parts shows every section of every page, for finding one by name.

### Creating a section

Use **+ Add section** in a page's workspace (or **New Section** on the Sections list), then:

1. Choose a template.
2. Enter the text and select the image or media requested by the template.
3. Choose **Generate Columns**.
4. Review the generated columns. Set the section name, order, and optional group.
5. Choose **Save Section**.

Save Section is disabled until columns are generated. Generating columns prepares an editable draft; it does not by itself save the section.

### Section groups and duplication

Give related sections the same **Section group** name to group them. Leave the field blank for an independent section.

**Duplicate section** asks for a new section name and copies that section and its columns. **Duplicate group** asks for a new group name and copies all sections in the group, including their columns. The copy is placed after the existing sections. Names must be valid and must not conflict with existing names.

## Columns

Columns are normally edited in the panel of the [page workspace](#the-page-workspace). The **Columns** list under Page parts shows every column with a preview and can open the classic column editor, which has the same fields on one long form.

## Writing and formatting content

The rich-text editor supports paragraphs, headings, emphasis, lists and links. Use its toolbar and check the preview before saving.

**Switch to HTML View** shows the underlying markup for advanced editing. Use it only when you are comfortable editing HTML, then switch back and check the result. Layout changes can affect how text and media fit on narrow screens.

Formatting fields (the **Layout** tab) offer pickers for margins, colors from the site's palette, and classes. **Switch to Formatting Mode** exposes the raw CSS classes and styles for advanced use.

Some content supports expandable text with **Show More** and **Show Less** controls. Review both the collapsed and expanded presentation on the website.

## Image files and groups

### The media library

Open **Media**. Files are shown as thumbnails, newest first, 24 to a page. Videos show a ▶ mark; hidden files are faded.

- **Group chips** filter by image group (each shows its count), **No group** shows files without one, and **All** shows everything.
- The **search box** searches name, caption, description and group.
- Click a thumbnail to open its **details**: the file, its caption and description, and **Used on**, the pages that show it as a picture, a video or in a group's slide show.

In the details you can change the file's **Group**, **Slide order** and **Enabled**, then **Save**. Choosing another group fills in the next slide number, so the file goes to the end of that group's slide show. **Edit caption, description or file** opens the full form (with the HTML view) and returns to the library; **View**, **History** and **Delete this file** are there too. Delete warns you when the file is used on a page.

### Uploading

Drop images or MP4 videos on the upload area, or choose **choose files**, then **Upload**. Up to 20 files go at once.

- Each file is named after itself without its extension. If the name is taken, it gets "-2", "-3" and so on, because pages refer to images by name.
- The file's type is read from the file itself; anything that is not an image or an MP4 video is skipped with a message.
- Enter a group to add the uploads to the end of that group's slide show.

**New Image** adds one file with its caption and description on the full form. An existing image's name cannot be changed, because pages refer to it.

### Uploading while editing content

The image picker in the column editor offers **New Image**. This opens the upload form without leaving the draft. Save the image to make it available in the picker, then select it and save the column. Uploading saves the image separately; cancelling the column does not undo it.

Image groups and section groups are separate concepts even when they use similar names.

## Blogs

Use **Blog** to create and maintain posts. The list shows each post's title with the start of its text, author, type, posted date and status, 20 to a page. Search by title, author, contents or posted date (YYYY-MM-DD).

Choose **New Blog** to create a post or **Edit** to update one. Enter the post fields and content, then save.

## Menus

Open **Menus** to arrange the **Header menu** and the **Footer** (switch between them at the top). Each is shown as a tree of up to two levels, like the public site: top items, and items inside them (a dropdown in the header, a column in the footer).

- **Move** an item with **↑** and **↓**, **←** (out one level) and **→** (inside the item above), or drag its **⠿** handle above, below or onto another item. Each move is saved as a draft at once.
- **Edit** an item by clicking its name: the panel holds **Label**, **Links to** (choose one of the site's pages, or type an address such as `https://example.com` or `mailto:you@example.com`), Enabled, and under **More settings** Access, Icon and Options. Addresses that could run code are refused.
- **Add an item** adds it at the end; drag it into place afterwards. **Delete this item** moves the items inside it to the top level.

Items that link to `/admin` can be moved but not changed. **Show the header menu as a list** opens the classic list, which also holds the old "Admin" menu entries; the admin sidebar itself no longer comes from them.

## Users and access

Use **Users** to create accounts and update names, email addresses, access levels, and roles. Access controls administrative capabilities; Roles are a separate field used by site content and navigation rules.

The system distinguishes regular users, read-only users, blog-capable users, administrators, and super users. Administrator and super accounts can change content and publish. Public sign-up is closed; administrators create accounts here.

New users need a password and confirmation. When editing an existing user, leave the password fields blank to keep the current password.

## Site setups

**Settings** edits the site's configuration on one form, in tabs, with one **Save**:

- **General**: configuration name, site name, owner, domain, host, address and the copyright line. Changing the configuration name suggests the site name, owner, address and database.
- **Email**: the mail server the contact form uses and the contact addresses and subject. **Send a test email** sends a short message to the "to" address using the settings as last saved, and reports whether it worked; save first if you changed them.
- **Appearance**: header, page and footer colors, each with a swatch and a small preview, and the background image.
- **Social links**: the footer's social icons; leave a box empty to hide its icon.
- **Advanced**: database, guest user name and the default setup.

If a required field on another tab is empty, Save opens that tab.

The required **Database** field stores a database name and defaults to `paul-carrick`. Publishing a new non-default setup provisions that database and its initial accounts; saving a draft does not. Publishing any Site Setup change synchronizes the setup catalog to all managed databases. See [Site databases](site-databases.md) for USER_PASSWORD, permissions, and recovery steps. Requests select a site by its Site URL hostname and longest matching path prefix. The default setup keeps the original application database connection.

Coordinate changes to domains, email settings, or the default setup with the person maintaining the running site; some deployment settings also come from the server environment.

## Keyboard shortcuts

On Chrome for Mac, use **Control + Option + letter**. On the configured desktop browser shortcuts for other platforms, the hint uses **Alt + Shift + letter**. Hover over an eligible button to see its shortcut.

- **S**: Save.
- **Escape**: Cancel, without modifier keys.
- **C**: Clear Sort.
- **N**: New or Next, only when the key identifies one action.
- **V**: View, when unique.
- **E**: Edit, when unique.
- **F**, **P**, **L**: First, Previous, Last, when unique.

Shortcuts are omitted when several visible actions would use the same key. For example, repeated row Edit buttons do not receive shortcuts. Disabled buttons have no active shortcut.

Escape gives open dialogs, menus, and selection controls priority rather than immediately cancelling the form. Within a native dropdown, close or leave the dropdown before using Escape to cancel the editor.

## Common questions

### Why don't visitors see my change?

It is a draft. Choose **Publish** in the top bar, check that its group is ticked, and publish it.

### Why is Save disabled?

The draft is not ready. For a new section, generate columns first. Some accounts also lack permission to save changes.

### Can I publish one page and not another?

Yes. On **Review and publish**, untick the groups to leave as drafts. A page's own changes (its settings, sections, columns and menu entries) are published together.

### Why did publishing say "Review them again"?

Someone saved a change in a ticked group after you opened the page. Nothing was published. Look at the list again and publish.

### Why is a keyboard shortcut missing?

The action may be disabled, or the same key may match several visible controls. Use the mouse or Tab and Enter to choose the intended button.

### How do I link directly to a help topic?

The entire guide is one document. Its table of contents links to stable section anchors. For example, the Pages topic is at `/admin/help#pages`, and Media is at `/admin/help#image-files-and-groups`.

[Back to table of contents](#table-of-contents)
