# Admin user guide

Use this guide to maintain the website through the admin sidebar. It covers creating content, arranging pages, managing navigation, and finding existing records. Open **Help** at the bottom of the sidebar to return here.

## Table of contents

- [Getting started](#getting-started)
- [Using list pages](#using-list-pages)
- [Pages, sections, and cells](#pages-sections-and-cells)
- [Pages](#pages)
- [Sections](#sections)
- [Cells](#cells)
- [Writing and formatting content](#writing-and-formatting-content)
- [Image files and groups](#image-files-and-groups)
- [Blogs](#blogs)
- [Menu items](#menu-items)
- [Footer items](#footer-items)
- [Users and access](#users-and-access)
- [Site setups](#site-setups)
- [Keyboard shortcuts](#keyboard-shortcuts)
- [Common questions](#common-questions)

## Getting started

Sign in with an account that has access to administration. Use the sidebar to choose the kind of record you want to work on. The sidebar entries come from the site's Admin menu, so their labels and order may vary.

A typical content change is:

1. Open **Pages** and find the page.
2. Choose **Edit**.
3. Find the section and choose **Edit Column** for the content you want to change.
4. Change the content and save it.
5. Review the page on the website.

Fields marked with an asterisk are required. Some editors keep Save disabled until the necessary data is available. A disabled Save button cannot be activated with its keyboard shortcut.

**Cancel** returns from an editor without saving its current changes. It does not undo changes you have already saved. When an editor opens inside another editor, saving may return the updated draft to the parent editor; save the parent too to finish the operation.

## Using list pages

List pages show records with **View**, **Edit**, and, where permitted, **Delete** actions. **New …** buttons appear above the lists where available.

### Sorting and column headings

Grey headings with arrows are sortable. Select a heading to sort by that column; select it again to reverse the direction. **Clear Sort** returns to the list's default ordering.

Lighter grey headings without arrows are labels, not sorting controls. For example, the Cell preview column is not sortable.

### Searching

Lists that support searching have a search form below the records. Fill in one or more fields, then choose **Search …**. Use **Clear Search** to remove the filters. Sorting and searching are separate controls.

### Pagination

**First**, **Previous**, **Next**, and **Last** move between result pages. The page indicator shows your current position. Unavailable directions appear disabled. The Cells list displays five records per page, with each preview in its own column.

### Deleting

Check the record carefully before confirming **Delete**. A confirmation asks whether to proceed. Cancel the confirmation if you selected the wrong record. The exact effect on related records depends on the record type; deleting a section also removes its cells.

## Pages, sections, and cells

The content structure has three levels:

- A **page** is a website destination with a title, name, access setting, and content.
- A **section** is an ordered block within a page. A section can contain one or more cells, arranged as columns.
- A **cell**, also called a **column** in editing controls, contains text, an image, video, or a combination of content and formatting.

A page's **Section Group** field and a section's **Section group** field serve different purposes. The page field identifies its section/content category. The section field groups neighboring sections so they can be kept together and duplicated as a unit.

## Pages

### Creating a page

1. Open **Pages**, then **New page**.
2. Enter the Page Title and a unique Page Name. The name identifies the page, so choose it deliberately.
3. Enter the required Section Group. Fill in Page Access if needed.
4. When the required name and section fields are complete, **Save Page** becomes available and **New Section** appears.
5. Choose **New Section** to build content, or save the page first.
6. Complete any offered menu/footer placement controls if you want to link the page from site navigation.
7. Save the page and review it on the website.

### Editing a page

The saved-page editor shows page fields and a preview of its sections. Section actions include **Edit Section**, **Duplicate Section** or **Duplicate Group**, and **Delete Section**. Each cell has its own **Edit Column** and **Delete Column** buttons.

**Add Section** opens the section editor for that page. Save changes in the editor you opened; after returning, review the page and save any remaining page-field changes.

### Section ordering

Sections have numeric order values. Use the page's renumbering control to normalize the sequence when needed. Grouped sections stay together during renumbering. Review the preview after changing order values.

## Sections

### Creating a section

1. Use **New Section** on the Sections list, or **Add Section** from a saved page.
2. Choose a template. Available column templates include Text Only, Image Only, dual-column text/image arrangements, and layouts with several columns.
3. Enter the text and select the image or media requested by the template.
4. Choose **Generate Columns**.
5. Review the generated cells. Set the section name, order, and optional group.
6. Choose **Save Section**.

Save Section is visible but disabled before columns are generated. Generating columns prepares an editable draft; it does not by itself save the section.

### Editing cells inside a section

Choose **Edit Column** for the desired cell. Save Column returns the edited cell to the section draft. Choose **Save Section** to persist the section changes. Cancel in a nested editor returns to the parent draft.

### Section groups and duplication

Give related sections the same **Section group** name to group them. Leave the field blank for an independent section.

From the page editor, **Duplicate Section** asks for a new section name and copies that section and its cells. **Duplicate Group** asks for a new group name and copies all sections in the group, including their cells. The copied group is placed after existing sections. Names must be valid and must not conflict with existing names.

The page preview uses stronger horizontal rules between groups and lighter rules within a group. Vertical rules separate adjacent cells.

## Cells

The Cells list shows Section, Name, Order, Image, Type, a rendered Cell preview, and action buttons. Images scale to fit the preview column and text wraps. Five cells appear per page.

Choose **Edit** to open a cell directly. You can also use **Edit Column** from a page or section. Depending on the editor and content type, controls include content, image/media selection, link, ordering, width, and formatting.

Use **Save Column** to finish. In a standalone cell editor, this saves the cell. Inside a section editor, it updates the section draft; save the section afterward.

## Writing and formatting content

The rich-text editor supports formatted text such as paragraphs, headings, emphasis, and lists. Use its toolbar to apply formatting and review the preview before saving.

**Switch to HTML View** exposes the underlying markup for advanced editing. Use it only when you are comfortable editing HTML, then switch back and check the result. Layout changes can affect how text and media fit on narrow screens.

Some content supports expandable text with **Show More** and **Show Less** controls. Review both the collapsed and expanded presentation on the website.

## Image files and groups

### Uploading an image

1. Open **Image Files**, then **New Image**.
2. Enter a unique Name and select the file to upload.
3. Choose a MIME type appropriate to the file, such as JPEG or PNG. Video entries use the appropriate video type.
4. Optionally set a Group, Slide Order, Caption, and Description.
5. Choose **Save Image**.

An existing image's Name is read-only. Content refers to images by name, so choose a useful name when creating the image.

### Groups

The Group field organizes images for selection and grouped displays. Use **Add Group** on a list row to assign a group. In an image form, enter a group or select an existing one. Slide Order controls ordering for displays that use ordered images.

Image groups and section groups are separate concepts even when they use similar names.

### Uploading while editing content

Image selectors can offer **New Image**. This opens an upload dialog without leaving the content draft. Save the image to make it available in the selector, then select it and finish saving the content. Cancel closes the image workflow without creating that image.

Uploading an image saves the image record separately; cancelling the surrounding page or section draft does not undo a completed image upload.

## Blogs

Use **Blogs** to create and maintain blog posts. The list includes author, title, posted date, content, and record actions. Search fields include author, title, posted date, and contents; follow the date format shown in the form.

Choose **New Blog** to create a post or **Edit** to update one. Enter the post fields and content, then save. **View** lets you inspect an existing post.

## Menu items

Menu items define navigation links. **Main** items are used for the website menu; **Admin** items are used for the admin sidebar.

1. Choose **New Menu Item** or edit an existing item.
2. Select Menu Type.
3. Enter the required Label and Menu Order. Lower order values appear earlier.
4. Set Link to the destination, such as a website page path.
5. Select a Parent menu to make the item a child/dropdown entry, or leave it blank for a top-level entry.
6. Set optional Icon, Options, and Access values only when needed.
7. Save and check the corresponding menu.

Access is a visibility setting tied to the site's access/role configuration. Preserve established conventions when editing it. Options and icon values also depend on the site's existing configuration.

The Help link is provided by the application beneath the configured admin menu entries.

## Footer items

Footer items define links in the website footer. Create or edit a footer item, supply its Label, Link, and Footer Order, and optionally select a Parent footer. Lower order values appear earlier.

Icon, Options, and Access fields work with the site's existing footer configuration. Save and review the footer on the website.

## Users and access

Use **Users** to create accounts and update names, email addresses, access levels, and roles. Access controls administrative capabilities; Roles are a separate field used by site content/navigation rules.

The system distinguishes regular users, read-only users, blog-capable users, administrators, and super users. Administrator and super accounts are treated as admin accounts by the content-editing permission checks. The controls available to a user depend on the area being accessed; visible controls do not necessarily grant permission to save.

New users need a password and confirmation. When editing an existing user, leave password fields blank to keep the current password. Enter a new password and matching confirmation only when changing it.

## Site setups

Site setups contain the website's configuration. The form groups information such as:

- Configuration name and default-setup selection.
- Owner, site name, domain, host, URL, and guest-user information.
- Email server settings and contact email addresses/subject.
- Header, footer, content colors, background, and other presentation settings.

Required fields are marked in the form. Save the setup and check the affected website behavior. Coordinate changes to domains, email settings, or the default setup with the person maintaining the running site; some deployment settings also come from the server environment.

## Keyboard shortcuts

On Chrome for Mac, use **Control + Option + letter**. On the configured desktop browser shortcuts for other platforms, the hint uses **Alt + Shift + letter**. Hover over an eligible button to see its shortcut.

- **S**: Save.
- **Escape**: Cancel, without modifier keys.
- **C**: Clear Sort.
- **N**: New or Next, only when the key identifies one action.
- **V**: View, when unique.
- **E**: Edit, when unique.
- **F**, **P**, **L**: First, Previous, Last, when unique.

Shortcuts are omitted when several visible actions would use the same key. For example, repeated row Edit buttons do not receive shortcuts. Top and bottom pagination can also make navigation shortcuts ambiguous. Disabled buttons have no active shortcut.

Escape gives open dialogs, menus, and selection controls priority rather than immediately cancelling the form. Within a native dropdown, close or leave the dropdown before using Escape to cancel the editor.

## Common questions

### Why is Save disabled?

The draft is not ready. For a new page, fill in Page Name and Section Group. For a new section, generate columns first. Some accounts also lack permission to save changes.

### Why did editing a column return me to another editor?

You opened a nested editor. Save Column updates the parent section draft; Save Section completes that section. A new page may hold that section as part of its own draft, which is completed with Save Page.

### Why is a column heading lighter grey?

It is a label rather than a sorting control. Only headings with arrows can change the order.

### Why is a keyboard shortcut missing?

The action may be disabled, or the same key may match multiple visible controls. Use the mouse or Tab and Enter to choose the intended button.

### How do I link directly to a help topic?

The entire guide is one document. Its table of contents links to stable section anchors. For example, the Pages topic is at `/admin/help#pages`, and Image Files is at `/admin/help#image-files-and-groups`. These addresses can also be used for future help links on individual admin pages.

[Back to table of contents](#table-of-contents)
