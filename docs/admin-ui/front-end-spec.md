# Admin front-end specification

Target: http://localhost:3000 • Inspected September 29, 2026

## Scope and evidence

All nine admin menu areas were visited. One representative record per area was opened in View and Edit; all exposed New screens were opened. This is a screen-template audit, not an inspection of every stored record. Screenshots and accessibility records describe the observed application, including defects. No Save, Delete, upload, Add Group, or Generate Columns action was invoked. No field data was entered. Add Section unexpectedly attempts an immediate creation; it failed validation rather than opening a form. Save behavior and validation on submission remain untested.

The initial Admin Dashboard gear link redirected to Login. After the user signed in, `/admin` displayed the dashboard. The Menu Item Edit record confirms the gear asset `/images/gear.svg` and destination `/admin`.

## Shared shell and layout

The observed viewport was approximately 674 × 689 pixels. Blue site header with uppercase white brand and collapsed hamburger navigation. Admin navigation forms a narrow blue left column with wrapping uppercase labels; the pale content panel holds forms and lists. Form labels appear above controls; text inputs are broad white rectangles with subtle borders and rounding. Forms and editors require vertical scrolling. Footer contains PERSONAL, PROFESSIONAL and OTHER links, social links and copyright. Dashboard explicitly discourages administration on mobile and recommends landscape. Desktop and breakpoint behavior were not tested.

## Coverage and screen contracts

| Area | List / View / Edit | New/Create |
|---|---|---|
| Site Setups | Captured | New Site Setup captured |
| Users | Captured | New User captured |
| Menu Items | Captured | New Menu Item captured |
| Footer Items | Captured | New Footer Item captured |
| Pages | Captured | New page captured; no Save/Cancel visible |
| Sections | Captured; two list records and contextual Page variant | No New link on list; Add Section fails before form |
| Cells | Captured; HTML and formatting modes | No New link on list; Generate Columns not invoked |
| Image Files | Captured | New Image captured |
| Blogs | Captured | New Blog captured |

### Site Setups

Identity fields: Configuration Name*, Default setup checkbox, Owner Name*, Site Name*, Site Domain*, Site Host*, Site URL*, Guest User Name*. SMTP fields: server, numeric port (New default 465), username, password, authentication (Select Authentication / Plain / Login), default domain. Contact fields: from, to, subject. Six required color selectors cover header/footer/container background and text. Background Image defaults to `none`. Social URL fields: Facebook, Twitter, Instagram, Linkedin, GitHub; Copyright. Edit populates values; New leaves most fields empty. Actions: Save Site Setup and Cancel. Color options contain duplicate and malformed quoted/truncated labels, recorded in raw evidence.

### Users

Email*, Name*, Password*, Access selector, Roles. New fields empty; Edit has email/name but blank password. Password is labeled required even in Edit. Access includes selectable levels detailed in the evidence. Save User and Cancel.

### Menu Items / Footer Items

Label*, Icon, Options, Link, Access, numeric order, parent selector. Menu Items additionally has Menu Type. Edit gear record uses Label Admin Dashboard, Icon `/images/gear.svg`, Link `/admin`; Menu Item Options `image-file`. Footer parent is OTHER. New fields mostly blank. Save Menu Item / Save Footer Item and Cancel.

### Pages

Edit: Name*, Section, Title, Access. Preview renders content with Edit/Delete Section and Edit/Delete Column links. Add Section below preview; Save Page and Cancel below that. New uses labels Page Title, Page Name*, Section Group*, Page Access, and Preview → No Contents. No save or cancel action appeared in its captured accessibility state.

### Sections

Searchable, paginated list with Content Type, Section Name, Image, URL, Description filters. Observed one record per page and 65 pages. List Edit for two records rendered Templates selector (Text Only, Image Only, Dual Column Text Left/Right, Three/Four/Five Column) and Generate Columns only. Contextual Edit Section from Page preview rendered Content Type selector, Section Order, existing column preview, Edit Column, Save Section and Cancel. Add Section led to `ActiveRecord::RecordInvalid`: “Page must exist, Section name can't be blank.” Error page exposes development exception details.

### Cells

Content Type selector (section_name), Cell Name, rich content editor, image selector, image type, link, numeric column order, margin top/left/bottom/right selectors and background color. Save Column and Cancel buttons. HTML toggle worked on Cell Edit, replacing the editor surface with a code view and changing action to Switch to Editor View. Formatting Mode replaced normal margin/color controls with Current entries (observed `m-3`), Delete and Add New Entry selector; toggle changes to Switch to Normal Mode. No entries were altered.

### Image Files

Name* (existing name read-only in Edit), Upload Image*, Mime Type, group entry and Add to Group, rich Caption and Description editors. Save Image and Cancel. List contains previews, per-record group controls, sorting and Name/Group/Caption/Description filters. Upload/group changes not invoked. Clicking Switch to HTML View showed no visible mode change in the recorded New Image state.

### Blogs

Author* (New defaults Paul Carrick), Title*, Visibility (Public default), Blog Type (Personal default), Post* rich editor. Save Blog Post and Cancel. List sorts Author/Title/Posted and searches Author/Title/Posted/Contents. Date hint says YYYY-DD-MM. Blog listing duplicated the shared footer. Clicking Switch to HTML View showed no visible mode change in the captured New Blog state.

## Interaction contracts and limits

Lists expose View/Edit/Delete, sort arrows, pagination and usually New links. View opens read-only details or rendered content; exact controls are captured below. Edit opens a populated form. New opens an empty/default form. Cancel was exercised for Site Setups, Users, Menu Items, Footer Items, Pages, Images, Blogs and Cells, returning to the associated list. Sidebar links allow navigation out of untouched forms.

Blog Title sorting changed route to `?direction=asc&sort=title` and reordered records. Clear Sort was clicked; ordering still appeared title-sorted in the following empty search, so reset semantics are uncertain. Empty Search Blogs submitted GET query fields without writing records; Clear Search was clicked. Sections Next opened page 2 with a different record. Only representative shared search/sort/pagination interactions were exercised; no filtering values were entered. Destructive and persistence actions remain untested by design.

## Screen-by-screen interaction log

### 02-dashboard

Interaction: Authenticated dashboard

Route: `http://localhost:3000/admin`

[Screenshot](screenshots/02-dashboard.jpg)

```text
	14 heading Admin Dashboard, Value: 1
		15 text Admin Dashboard
	16 text Please chose an item for the menu on the left.
	17 container
		18 text It is  highly  recommended that administration is not performed on a mobile device. There is too much information to display. If you must use a mobile device we recommend landscape mode.
	19 container
```

### 03-site-setups-list

Interaction: Click SITE SETUPS

Route: `http://localhost:3000/admin/site_setups`

[Screenshot](screenshots/03-site-setups-list.jpg)

```text
	15 link Description: Configuration Name ↓↑, Value: localhost:3000/admin/site_setups?direction=asc&sort=configuration_name
	16 link Description: Site Name ↓↑, Value: localhost:3000/admin/site_setups?direction=asc&sort=site_name
	17 link Description: Owner ↓↑, Value: localhost:3000/admin/site_setups?direction=asc&sort=owner_name
	18 link Description: Domain ↓↑, Value: localhost:3000/admin/site_setups?direction=asc&sort=site_domain
	19 link Description: Host ↓↑, Value: localhost:3000/admin/site_setups?direction=asc&sort=site_host
	20 link Description: URL ↓↑, Value: localhost:3000/admin/site_setups?direction=asc&sort=site_url
	21 link Description: Clear Sort, Value: localhost:3000/admin/site_setups#
	22 container
		23 text default Paul Carrick Paul Carrick paul-carrick.com paul-carrick.com https://paul-carrick.com
		24 container
			25 link Description: View, Value: localhost:3000/admin/site_setups/1
			26 link Description: Edit, Value: localhost:3000/admin/site_setups/1/edit
			27 link Description: Delete, Value: localhost:3000/admin/site_setups/1/delete
	28 link Description: New Site Setup, Value: localhost:3000/admin/site_setups/new
	29 container Pagination
		30 content list
			31 text Page 1 of 1
			32 link Description: First, Value: localhost:3000/admin/site_setups?page=1
			33 link Description: Previous, Value: localhost:3000/admin/site_setups
			34 link Description: Next, Value: localhost:3000/admin/site_setups
			35 link Description: Last, Value: localhost:3000/admin/site_setups?page=1
	36 container
```

### 04-site-setups-edit

Interaction: Click first row Edit

Route: `http://localhost:3000/admin/site_setups/1/edit`

[Screenshot](screenshots/04-site-setups-edit.jpg)

```text
	15 container
		16 heading Edit Site Setup, Value: 1
			17 text Edit Site Setup
		18 text Configuration Name*
		19 text field (settable) Configuration Name*, Value: default, ID: site_setup_configuration_name
		20 text Default setup
		21 checkbox (settable, integer) Description: Default setup, Value: 1, ID: site_setup_default_setup
		22 text Owner Name*
		23 text field (settable) Owner Name*, Value: Paul Carrick, ID: site_setup_owner_name
		24 text Site Name*
		25 text field (settable) Site Name*, Value: Paul Carrick, ID: site_setup_site_name
		26 text Site Domain*
		27 text field (settable) Site Domain*, Value: paul-carrick.com, ID: site_setup_site_domain
		28 text Site Host*
		29 text field (settable) Site Host*, Value: paul-carrick.com, ID: site_setup_site_host
		30 text Site URL*
		31 text field (settable) Site URL*, Value: https://paul-carrick.com, ID: site_setup_site_url
		32 text Guest User Name*
		33 text field (settable) Guest User Name*, Value: <redacted>
		34 text Email server (SMTP host)
		35 text field (settable) Email server (SMTP host), Value: email-smtp.us-west-2.amazonaws.com, ID: site_setup_smtp_server
		36 text Email Server Port
		37 combo box (settable) Email Server Port, Value: 465, ID: site_setup_smtp_port
		38 text Email server username
		39 text field (settable) Email server username, Value: <redacted>
		40 text Email server password
		41 text field (settable) Email server password
		42 text SMTP Server Authentication
		43 pop up button (collapsed, settable) SMTP Server Authentication, Value: Login, ID: site_setup_smtp_authentication, Secondary Actions: Expand
			44 menu
				45 Select Authentication
				46 Plain
		48 text Email server default domain
		49 text field (settable) Email server default domain, Value: paul-carrick.com, ID: site_setup_smtp_domain
		50 text Contact email from address
		51 text field (settable) Contact email from address, Value: <redacted>
		52 text Contact email to address
		53 text field (settable) Contact email to address, Value: <redacted>
		54 text Contact Email subject line
		55 text field (settable) Contact Email subject line, Value: <redacted>
		56 text Header Background Color*
		57 pop up button (collapsed, settable) Header Background Color*, Value: Default, ID: site_setup_header_background, Secondary Actions: Expand
			58 menu
				62 Red
				63 Green
				64 Blue
				65 Gray
				66 Yellow
				67 Cyan
				68 Magenta
				69 Lime
				70 Silver
				71 Maroon
				72 Olive
				73 Green
				74 Purple
				75 Teal
				76 Navy
				77 Orange
				78 Gainsboro
		184 text Header Text Color*
		185 pop up button (collapsed, settable) Header Text Color*, Value: White, ID: site_setup_header_text_color, Secondary Actions: Expand
			186 menu
				190 Red
				191 Green
				192 Blue
				193 Gray
				194 Yellow
				195 Cyan
				196 Magenta
				197 Lime
				198 Silver
				199 Maroon
				200 Olive
				201 Green
				202 Purple
				203 Teal
				204 Navy
				205 Orange
				206 Gainsboro
		312 text Footer Background Color*
		313 pop up button (collapsed, settable) Footer Background Color*, Value: Default, ID: site_setup_footer_background, Secondary Actions: Expand
			314 menu
				318 Red
				319 Green
				320 Blue
				321 Gray
				322 Yellow
				323 Cyan
				324 Magenta
				325 Lime
				326 Silver
				327 Maroon
				328 Olive
				329 Green
				330 Purple
				331 Teal
				332 Navy
				333 Orange
				334 Gainsboro
		440 text Footer Text Color*
		441 pop up button (collapsed, settable) Footer Text Color*, Value: White, ID: site_setup_footer_text_color, Secondary Actions: Expand
			442 menu
				446 Red
				447 Green
				448 Blue
				449 Gray
				450 Yellow
				451 Cyan
				452 Magenta
				453 Lime
				454 Silver
				455 Maroon
				456 Olive
				457 Green
				458 Purple
				459 Teal
				460 Navy
				461 Orange
				462 Gainsboro
		568 text Container Background Color*
		569 pop up button (collapsed, settable) Container Background Color*, Value: White, ID: site_setup_container_background, Secondary Actions: Expand
			570 menu
				574 Red
				575 Green
				576 Blue
				577 Gray
				578 Yellow
				579 Cyan
				580 Magenta
				581 Lime
				582 Silver
				583 Maroon
				584 Olive
				585 Green
				586 Purple
				587 Teal
				588 Navy
				589 Orange
				590 Gainsboro
		696 text Container Text Color*
		697 pop up button (collapsed, settable) Container Text Color*, Value: Black, ID: site_setup_container_text_color, Secondary Actions: Expand
			698 menu
				702 Red
				703 Green
				704 Blue
				705 Gray
				706 Yellow
				707 Cyan
				708 Magenta
				709 Lime
				710 Silver
				711 Maroon
				712 Olive
				713 Green
				714 Purple
				715 Teal
				716 Navy
				717 Orange
				718 Gainsboro
		824 text Background Image
		825 text field (settable) Background Image, Value: none, ID: site_setup_page_background_image
		826 text Facebook URL
		827 text field (settable) Facebook URL, Value: https://www.facebook.com/paul.j.carrick, ID: site_setup_facebook_url
		828 text Twitter URL
		829 text field (settable) Twitter URL, Value: https://x.com/PaulJCarrick, ID: site_setup_twitter_url
		830 text Instagram URL
		831 text field (settable) Instagram URL, Value: https://www.instagram.com/pauljcarrick/, ID: site_setup_instagram_url
		832 text Linkedin URL
		833 text field (settable) Linkedin URL, Value: https://www.linkedin.com/in/pauljcarrick/, ID: site_setup_linkedin_url
		834 text GitHub URL
		835 text field (settable) GitHub URL, Value: https://github.com/PaulCarrick, ID: site_setup_github_url
		836 text Copyright
		837 text field (settable) Copyright, Value: Copyright © 2024 Paul Carrick all rights reserved, ID: site_setup_copyright
		838 text * - Required Fields
		839 button Save Site Setup
		840 link Description: Cancel, Value: localhost:3000/admin/site_setups
	841 container
```

### 05-site-setups-new

Interaction: Cancel Edit; click New Site Setup

Route: `http://localhost:3000/admin/site_setups/new`

[Screenshot](screenshots/05-site-setups-new.jpg)

```text
	15 container
		16 heading New Site Setup, Value: 1
			17 text New Site Setup
		18 text Configuration Name*
		19 text field (settable) Configuration Name*, ID: site_setup_configuration_name
		20 text Default setup
		21 checkbox (settable, integer) Description: Default setup, Value: 0, ID: site_setup_default_setup
		22 text Owner Name*
		23 text field (settable) Owner Name*, ID: site_setup_owner_name
		24 text Site Name*
		25 text field (settable) Site Name*, ID: site_setup_site_name
		26 text Site Domain*
		27 text field (settable) Site Domain*, ID: site_setup_site_domain
		28 text Site Host*
		29 text field (settable) Site Host*, ID: site_setup_site_host
		30 text Site URL*
		31 text field (settable) Site URL*, ID: site_setup_site_url
		32 text Guest User Name*
		33 text field (settable) Guest User Name*, Value: <redacted>
		34 text Email server (SMTP host)
		35 text field (settable) Email server (SMTP host), ID: site_setup_smtp_server
		36 text Email Server Port
		37 combo box (settable) Email Server Port, Value: 465, ID: site_setup_smtp_port
		38 text Email server username
		39 text field (settable) Email server username
		40 text Email server password
		41 text field (settable) Email server password
		42 text SMTP Server Authentication
		43 pop up button (collapsed, settable) SMTP Server Authentication, Value: Select Authentication, ID: site_setup_smtp_authentication, Secondary Actions: Expand
			44 menu
				46 Plain
				47 Login
		48 text Email server default domain
		49 text field (settable) Email server default domain, ID: site_setup_smtp_domain
		50 text Contact email from address
		51 text field (settable) Contact email from address
		52 text Contact email to address
		53 text field (settable) Contact email to address
		54 text Contact Email subject line
		55 text field (settable) Contact Email subject line
		56 text Header Background Color*
		57 pop up button (collapsed, settable) Header Background Color*, Value: Default, ID: site_setup_header_background, Secondary Actions: Expand
			58 menu
				62 Red
				63 Green
				64 Blue
				65 Gray
				66 Yellow
				67 Cyan
				68 Magenta
				69 Lime
				70 Silver
				71 Maroon
				72 Olive
				73 Green
				74 Purple
				75 Teal
				76 Navy
				77 Orange
				78 Gainsboro
		184 text Header Text Color*
		185 pop up button (collapsed, settable) Header Text Color*, ID: site_setup_header_text_color, Secondary Actions: Expand
			186 menu
				191 Red
				192 Green
				193 Blue
				194 Gray
				195 Yellow
				196 Cyan
				197 Magenta
				198 Lime
				199 Silver
				200 Maroon
				201 Olive
				202 Green
				203 Purple
				204 Teal
				205 Navy
				206 Orange
				207 Gainsboro
		313 text Footer Background Color*
		314 pop up button (collapsed, settable) Footer Background Color*, Value: Default, ID: site_setup_footer_background, Secondary Actions: Expand
			315 menu
				319 Red
				320 Green
				321 Blue
				322 Gray
				323 Yellow
				324 Cyan
				325 Magenta
				326 Lime
				327 Silver
				328 Maroon
				329 Olive
				330 Green
				331 Purple
				332 Teal
				333 Navy
				334 Orange
				335 Gainsboro
		441 text Footer Text Color*
		442 pop up button (collapsed, settable) Footer Text Color*, ID: site_setup_footer_text_color, Secondary Actions: Expand
			443 menu
				448 Red
				449 Green
				450 Blue
				451 Gray
				452 Yellow
				453 Cyan
				454 Magenta
				455 Lime
				456 Silver
				457 Maroon
				458 Olive
				459 Green
				460 Purple
				461 Teal
				462 Navy
				463 Orange
				464 Gainsboro
		570 text Container Background Color*
		571 pop up button (collapsed, settable) Container Background Color*, ID: site_setup_container_background, Secondary Actions: Expand
			572 menu
				577 Red
				578 Green
				579 Blue
				580 Gray
				581 Yellow
				582 Cyan
				583 Magenta
				584 Lime
				585 Silver
				586 Maroon
				587 Olive
				588 Green
				589 Purple
				590 Teal
				591 Navy
				592 Orange
				593 Gainsboro
		699 text Container Text Color*
		700 pop up button (collapsed, settable) Container Text Color*, ID: site_setup_container_text_color, Secondary Actions: Expand
			701 menu
				706 Red
				707 Green
				708 Blue
				709 Gray
				710 Yellow
				711 Cyan
				712 Magenta
				713 Lime
				714 Silver
				715 Maroon
				716 Olive
				717 Green
				718 Purple
				719 Teal
				720 Navy
				721 Orange
				722 Gainsboro
		828 text Background Image
		829 text field (settable) Background Image, Value: none, ID: site_setup_page_background_image
		830 text Facebook URL
		831 text field (settable) Facebook URL, ID: site_setup_facebook_url
		832 text Twitter URL
		833 text field (settable) Twitter URL, ID: site_setup_twitter_url
		834 text Instagram URL
		835 text field (settable) Instagram URL, ID: site_setup_instagram_url
		836 text Linkedin URL
		837 text field (settable) Linkedin URL, ID: site_setup_linkedin_url
		838 text GitHub URL
		839 text field (settable) GitHub URL, ID: site_setup_github_url
		840 text Copyright
		841 text field (settable) Copyright, ID: site_setup_copyright
		842 text * - Required Fields
		843 button Save Site Setup
		844 link Description: Cancel, Value: localhost:3000/admin/site_setups
	845 container
```

### 06-users-list

Interaction: Click Users

Route: `http://localhost:3000/admin/users`

[Screenshot](screenshots/06-users-list.jpg)

```text
	15 heading Manage Users, Value: 1
		16 text Manage Users
	17 link Description: Email ↓↑, Value: localhost:3000/admin/users?direction=asc&sort=email
	18 link Description: Name ↓↑, Value: localhost:3000/admin/users?direction=asc&sort=name
	19 link Description: Access ↓↑, Value: localhost:3000/admin/users?direction=asc&sort=access
	20 link Description: Roles ↓↑, Value: localhost:3000/admin/users?direction=asc&sort=roles
	21 container
		22 text guest@paul-carrick.com Guest User regular None
		23 container
			24 link Description: View, Value: localhost:3000/admin/users/2
			25 link Description: Edit, Value: localhost:3000/admin/users/2/edit
			26 link Description: Delete, Value: localhost:3000/admin/users/2/delete
		27 text paul@paul-carrick.com Paul Carrick admin None
		28 container
			29 link Description: View, Value: localhost:3000/admin/users/1
			30 link Description: Edit, Value: localhost:3000/admin/users/1/edit
			31 link Description: Delete, Value: localhost:3000/admin/users/1/delete
		32 text professional@paul-carrick.com Professional read_only professional
		33 container
			34 link Description: View, Value: localhost:3000/admin/users/4
			35 link Description: Edit, Value: localhost:3000/admin/users/4/edit
			36 link Description: Delete, Value: localhost:3000/admin/users/4/delete
		37 text readonly@paul-paulcarrick.com Read Only read_only None
		38 container
			39 link Description: View, Value: localhost:3000/admin/users/3
			40 link Description: Edit, Value: localhost:3000/admin/users/3/edit
			41 link Description: Delete, Value: localhost:3000/admin/users/3/delete
	42 link Description: New User, Value: localhost:3000/admin/users/new
	43 container Pagination
		44 content list
			45 text Page 1 of 1
			46 link Description: First, Value: localhost:3000/admin/users?page=1
			47 link Description: Previous, Value: localhost:3000/admin/users
			48 link Description: Next, Value: localhost:3000/admin/users
			49 link Description: Last, Value: localhost:3000/admin/users?page=1
	50 container
```

### 07-users-edit

Interaction: Click first row Edit

Route: `http://localhost:3000/admin/users/2/edit`

[Screenshot](screenshots/07-users-edit.jpg)

```text
	15 container
		16 heading Edit User, Value: 1
			17 text Edit User
		18 text Email*
		19 text field (settable) Email*, Value: <redacted>
		20 text Name*
		21 text field (settable) Name*, Value: <redacted>
		22 text Password*
		23 text field (settable) Password*
		24 text Access
		25 pop up button (collapsed, settable) Access, Value: Regular, ID: user_access, Secondary Actions: Expand
			26 menu
				28 Read Only
				29 Post Blogs
				30 Administrator
				31 Super User
		32 text Roles
		33 text field (settable) Roles, ID: user_roles
		34 text * - Required Fields
		35 button Save User
		36 link Description: Cancel, Value: localhost:3000/admin/users
	37 container
```

### 08-users-new

Interaction: Cancel Edit; click New User

Route: `http://localhost:3000/admin/users/new`

[Screenshot](screenshots/08-users-new.jpg)

```text
	15 container
		16 heading New User, Value: 1
			17 text New User
		18 text Email*
		19 text field (settable) Email*
		20 text Name*
		21 text field (settable) Name*
		22 text Password*
		23 text field (settable) Password*
		24 text Access
		25 pop up button (collapsed, settable) Access, ID: user_access, Secondary Actions: Expand
			26 menu
				28 Regular
				29 Read Only
				30 Post Blogs
				31 Administrator
				32 Super User
		33 text Roles
		34 text field (settable) Roles, ID: user_roles
		35 text * - Required Fields
		36 button Save User
		37 link Description: Cancel, Value: localhost:3000/admin/users
	38 container
```

### 09-menu-items-list

Interaction: Click Menu Items

Route: `http://localhost:3000/admin/menu_items`

[Screenshot](screenshots/09-menu-items-list.jpg)

```text
	15 link Description: Menu Type ↓↑, Value: localhost:3000/admin/menu_items?direction=asc&sort=menu_type
	16 link Description: Label ↓↑, Value: localhost:3000/admin/menu_items?direction=asc&sort=label
	17 link Description: Menu Order ↓↑, Value: localhost:3000/admin/menu_items?direction=asc&sort=menu_order
	18 link Description: Access ↓↑, Value: localhost:3000/admin/menu_items?direction=asc&sort=access
	19 link Description: Link ↓↑, Value: localhost:3000/admin/menu_items?direction=asc&sort=link
	20 link Description: Clear Sort, Value: localhost:3000/admin/menu_items#
	21 container
		22 text Main Admin Dashboard 6 /admin
		23 container
			24 link Description: View, Value: localhost:3000/admin/menu_items/24
			25 link Description: Edit, Value: localhost:3000/admin/menu_items/24/edit
			26 link Description: Delete, Value: localhost:3000/admin/menu_items/24/delete
		27 text Main Bio 4 /bio
		28 container
			29 link Description: View, Value: localhost:3000/admin/menu_items/10
			30 link Description: Edit, Value: localhost:3000/admin/menu_items/10/edit
			31 link Description: Delete, Value: localhost:3000/admin/menu_items/10/delete
		32 text Main Blogs 5 /blogs?blog_type=Personal
		33 container
			34 link Description: View, Value: localhost:3000/admin/menu_items/20
			35 link Description: Edit, Value: localhost:3000/admin/menu_items/20/edit
			36 link Description: Delete, Value: localhost:3000/admin/menu_items/20/delete
		37 text Main Blogs 4 /blogs?blog_type=Professional
		38 container
			39 link Description: View, Value: localhost:3000/admin/menu_items/15
			40 link Description: Edit, Value: localhost:3000/admin/menu_items/15/edit
			41 link Description: Delete, Value: localhost:3000/admin/menu_items/15/delete
		42 text Admin Blogs 9 /admin/blog_posts
		43 container
			44 link Description: View, Value: localhost:3000/admin/menu_items/16
			45 link Description: Edit, Value: localhost:3000/admin/menu_items/16/edit
			46 link Description: Delete, Value: localhost:3000/admin/menu_items/16/delete
		47 text Admin Cells 7 /admin/cells
		48 container
			49 link Description: View, Value: localhost:3000/admin/menu_items/26
			50 link Description: Edit, Value: localhost:3000/admin/menu_items/26/edit
			51 link Description: Delete, Value: localhost:3000/admin/menu_items/26/delete
		52 text Main Contact 4 /contacts/new
		53 container
			54 link Description: View, Value: localhost:3000/admin/menu_items/4
			55 link Description: Edit, Value: localhost:3000/admin/menu_items/4/edit
			56 link Description: Delete, Value: localhost:3000/admin/menu_items/4/delete
		57 text Main Employment 2 /employment
		58 container
			59 link Description: View, Value: localhost:3000/admin/menu_items/13
			60 link Description: Edit, Value: localhost:3000/admin/menu_items/13/edit
			61 link Description: Delete, Value: localhost:3000/admin/menu_items/13/delete
		62 text Main Family 1 /family
		63 container
			64 link Description: View, Value: localhost:3000/admin/menu_items/7
			65 link Description: Edit, Value: localhost:3000/admin/menu_items/7/edit
			66 link Description: Delete, Value: localhost:3000/admin/menu_items/7/delete
		67 text Admin Footer Items 4 /admin/footer_items
		68 container
			69 link Description: View, Value: localhost:3000/admin/menu_items/22
			70 link Description: Edit, Value: localhost:3000/admin/menu_items/22/edit
			71 link Description: Delete, Value: localhost:3000/admin/menu_items/22/delete
		72 text Main Hobbies and Activities 3 /hobby
		73 container
			74 link Description: View, Value: localhost:3000/admin/menu_items/9
			75 link Description: Edit, Value: localhost:3000/admin/menu_items/9/edit
			76 link Description: Delete, Value: localhost:3000/admin/menu_items/9/delete
		77 text Main Home 1 !professional /
		78 container
			79 link Description: View, Value: localhost:3000/admin/menu_items/1
			80 link Description: Edit, Value: localhost:3000/admin/menu_items/1/edit
			81 link Description: Delete, Value: localhost:3000/admin/menu_items/1/delete
		82 text Admin Image Files 8 /admin/image_files
		83 container
			84 link Description: View, Value: localhost:3000/admin/menu_items/19
			85 link Description: Edit, Value: localhost:3000/admin/menu_items/19/edit
			86 link Description: Delete, Value: localhost:3000/admin/menu_items/19/delete
		87 text Main Login 7 /users/sign_in
		88 container
			89 link Description: View, Value: localhost:3000/admin/menu_items/6
			90 link Description: Edit, Value: localhost:3000/admin/menu_items/6/edit
			91 link Description: Delete, Value: localhost:3000/admin/menu_items/6/delete
		92 text Admin Menu Items 3 /admin/menu_items
		93 container
			94 link Description: View, Value: localhost:3000/admin/menu_items/21
			95 link Description: Edit, Value: localhost:3000/admin/menu_items/21/edit
			96 link Description: Delete, Value: localhost:3000/admin/menu_items/21/delete
		97 text Main Overview 1 /overview
		98 container
			99 link Description: View, Value: localhost:3000/admin/menu_items/12
			100 link Description: Edit, Value: localhost:3000/admin/menu_items/12/edit
			101 link Description: Delete, Value: localhost:3000/admin/menu_items/12/delete
		102 text Admin Pages 5 /admin/pages
		103 container
			104 link Description: View, Value: localhost:3000/admin/menu_items/17
			105 link Description: Edit, Value: localhost:3000/admin/menu_items/17/edit
			106 link Description: Delete, Value: localhost:3000/admin/menu_items/17/delete
		107 text Main Personal 2 !professional
		108 container
			109 link Description: View, Value: localhost:3000/admin/menu_items/2
			110 link Description: Edit, Value: localhost:3000/admin/menu_items/2/edit
			111 link Description: Delete, Value: localhost:3000/admin/menu_items/2/delete
		112 text Main Portfolio 3 /portfolio
		113 container
			114 link Description: View, Value: localhost:3000/admin/menu_items/14
			115 link Description: Edit, Value: localhost:3000/admin/menu_items/14/edit
			116 link Description: Delete, Value: localhost:3000/admin/menu_items/14/delete
		117 text Main Professional 3
		118 container
			119 link Description: View, Value: localhost:3000/admin/menu_items/3
			120 link Description: Edit, Value: localhost:3000/admin/menu_items/3/edit
			121 link Description: Delete, Value: localhost:3000/admin/menu_items/3/delete
	122 link Description: New Menu Item, Value: localhost:3000/admin/menu_items/new
	123 container Pagination
		124 content list
			125 text Page 1 of 2
			126 link Description: First, Value: localhost:3000/admin/menu_items?page=1
			127 link Description: Previous, Value: localhost:3000/admin/menu_items
			128 link Description: Next, Value: localhost:3000/admin/menu_items?page=2
			129 link Description: Last, Value: localhost:3000/admin/menu_items?page=2
	130 container
```

### 10-menu-items-edit

Interaction: Click first row Edit

Route: `http://localhost:3000/admin/menu_items/24/edit`

[Screenshot](screenshots/10-menu-items-edit.jpg)

```text
	15 container
		16 heading Edit Menu Item, Value: 1
			17 text Edit Menu Item
		18 text Menu Type
		19 pop up button (collapsed, settable) Menu Type, Value: Main, ID: menu_item_menu_type, Secondary Actions: Expand
			20 menu
				22 Admin
		23 text Label*
		24 text field (settable) Label*, Value: Admin Dashboard, ID: menu_item_label
		25 text Icon
		26 text field (settable) Icon, Value: /images/gear.svg, ID: menu_item_icon
		27 text Options
		28 text field (settable) Options, Value: image-file, ID: menu_item_options
		29 text Link
		30 text field (settable) Link, Value: /admin, ID: menu_item_link
		31 text Access
		32 text field (settable) Access, ID: menu_item_access
		33 text Menu Order*
		34 stepper (settable, integer) Value: 6, ID: menu-order-field
		35 text Parent menu
		36 pop up button (collapsed, settable) Parent menu, ID: menu_item_parent_id, Secondary Actions: Expand
			37 menu
				39 Professional
				40 Search
				41 Contact
				42 Blogs
				43 Blogs
				44 Login
				45 Personal
				46 Home
				47 Admin Dashboard
				48 Pages
				49 Sections
				50 Menu Items
				51 Footer Items
				52 Users
				53 Site Setups
				54 Image Files
				55 Blogs
				56 Cells
				57 Bio
				58 Employment
				59 Family
				60 Hobbies and Activities
				61 Where Paul Lives
				62 Portfolio
				63 Test Page
				64 Overview
		65 text * - Required Fields
		66 button Save Menu Item
		67 link Description: Cancel, Value: localhost:3000/admin/menu_items
	68 container
```

### 11-menu-items-new

Interaction: Cancel Edit; click New Menu Item

Route: `http://localhost:3000/admin/menu_items/new`

[Screenshot](screenshots/11-menu-items-new.jpg)

```text
	15 container
		16 heading New Menu Item, Value: 1
			17 text New Menu Item
		18 text Menu Type
		19 pop up button (collapsed, settable) Menu Type, ID: menu_item_menu_type, Secondary Actions: Expand
			20 menu
				22 Main
				23 Admin
		24 text Label*
		25 text field (settable) Label*, ID: menu_item_label
		26 text Icon
		27 text field (settable) Icon, ID: menu_item_icon
		28 text Options
		29 text field (settable) Options, ID: menu_item_options
		30 text Link
		31 text field (settable) Link, ID: menu_item_link
		32 text Access
		33 text field (settable) Access, ID: menu_item_access
		34 text Menu Order*
		35 stepper (settable) menu-order-field
		36 text Parent menu
		37 pop up button (collapsed, settable) Parent menu, ID: menu_item_parent_id, Secondary Actions: Expand
			38 menu
				40 Professional
				41 Search
				42 Contact
				43 Blogs
				44 Blogs
				45 Login
				46 Personal
				47 Home
				48 Admin Dashboard
				49 Pages
				50 Sections
				51 Menu Items
				52 Footer Items
				53 Users
				54 Site Setups
				55 Image Files
				56 Blogs
				57 Cells
				58 Bio
				59 Employment
				60 Family
				61 Hobbies and Activities
				62 Where Paul Lives
				63 Portfolio
				64 Test Page
				65 Overview
		66 text * - Required Fields
		67 button Save Menu Item
		68 link Description: Cancel, Value: localhost:3000/admin/menu_items
	69 container
```

### 12-footer-items-list

Interaction: Click Footer Items

Route: `http://localhost:3000/admin/footer_items`

[Screenshot](screenshots/12-footer-items-list.jpg)

```text
	15 link Description: Label ↓↑, Value: localhost:3000/admin/footer_items?direction=asc&sort=label
	16 link Description: Footer Order ↓↑, Value: localhost:3000/admin/footer_items?direction=asc&sort=footer_order
	17 link Description: Link ↓↑, Value: localhost:3000/admin/footer_items?direction=asc&sort=link
	18 link Description: Clear Sort, Value: localhost:3000/admin/footer_items#
	19 container
		20 text Admin Dashboard 16 /admin
		21 container
			22 link Description: View, Value: localhost:3000/admin/footer_items/15
			23 link Description: Edit, Value: localhost:3000/admin/footer_items/15/edit
			24 link Description: Delete, Value: localhost:3000/admin/footer_items/15/delete
		25 text Biography 5 /bio
		26 container
			27 link Description: View, Value: localhost:3000/admin/footer_items/5
			28 link Description: Edit, Value: localhost:3000/admin/footer_items/5/edit
			29 link Description: Delete, Value: localhost:3000/admin/footer_items/5/delete
		30 text Blog 6 /blogs?blog_type=Personal
		31 container
			32 link Description: View, Value: localhost:3000/admin/footer_items/6
			33 link Description: Edit, Value: localhost:3000/admin/footer_items/6/edit
			34 link Description: Delete, Value: localhost:3000/admin/footer_items/6/delete
		35 text Blog 11 /blogs?blog_type=Professional
		36 container
			37 link Description: View, Value: localhost:3000/admin/footer_items/11
			38 link Description: Edit, Value: localhost:3000/admin/footer_items/11/edit
			39 link Description: Delete, Value: localhost:3000/admin/footer_items/11/delete
		40 text Contact Paul 13 /contacts/new
		41 container
			42 link Description: View, Value: localhost:3000/admin/footer_items/13
			43 link Description: Edit, Value: localhost:3000/admin/footer_items/13/edit
			44 link Description: Delete, Value: localhost:3000/admin/footer_items/13/delete
		45 text Employment History 9 /employment
		46 container
			47 link Description: View, Value: localhost:3000/admin/footer_items/9
			48 link Description: Edit, Value: localhost:3000/admin/footer_items/9/edit
			49 link Description: Delete, Value: localhost:3000/admin/footer_items/9/delete
		50 text Hobbies and Activities 4 /hobby
		51 container
			52 link Description: View, Value: localhost:3000/admin/footer_items/4
			53 link Description: Edit, Value: localhost:3000/admin/footer_items/4/edit
			54 link Description: Delete, Value: localhost:3000/admin/footer_items/4/delete
		55 text Login 15 /users/sign_in
		56 container
			57 link Description: View, Value: localhost:3000/admin/footer_items/16
			58 link Description: Edit, Value: localhost:3000/admin/footer_items/16/edit
			59 link Description: Delete, Value: localhost:3000/admin/footer_items/16/delete
		60 text OTHER 12
		61 container
			62 link Description: View, Value: localhost:3000/admin/footer_items/12
			63 link Description: Edit, Value: localhost:3000/admin/footer_items/12/edit
			64 link Description: Delete, Value: localhost:3000/admin/footer_items/12/delete
		65 text PERSONAL 1
		66 container
			67 link Description: View, Value: localhost:3000/admin/footer_items/1
			68 link Description: Edit, Value: localhost:3000/admin/footer_items/1/edit
			69 link Description: Delete, Value: localhost:3000/admin/footer_items/1/delete
		70 text PROFESSIONAL 7
		71 container
			72 link Description: View, Value: localhost:3000/admin/footer_items/7
			73 link Description: Edit, Value: localhost:3000/admin/footer_items/7/edit
			74 link Description: Delete, Value: localhost:3000/admin/footer_items/7/delete
		75 text Paul's Family 2 /family
		76 container
			77 link Description: View, Value: localhost:3000/admin/footer_items/2
			78 link Description: Edit, Value: localhost:3000/admin/footer_items/2/edit
			79 link Description: Delete, Value: localhost:3000/admin/footer_items/2/delete
		80 text Portfolio 10 /portfolio
		81 container
			82 link Description: View, Value: localhost:3000/admin/footer_items/10
			83 link Description: Edit, Value: localhost:3000/admin/footer_items/10/edit
			84 link Description: Delete, Value: localhost:3000/admin/footer_items/10/delete
		85 text Professional Overview 8 /overview
		86 container
			87 link Description: View, Value: localhost:3000/admin/footer_items/8
			88 link Description: Edit, Value: localhost:3000/admin/footer_items/8/edit
			89 link Description: Delete, Value: localhost:3000/admin/footer_items/8/delete
		90 text Search Website 14 /search/new
		91 container
			92 link Description: View, Value: localhost:3000/admin/footer_items/14
			93 link Description: Edit, Value: localhost:3000/admin/footer_items/14/edit
			94 link Description: Delete, Value: localhost:3000/admin/footer_items/14/delete
		95 text Test Page 5 /test-page
		96 container
			97 link Description: View, Value: localhost:3000/admin/footer_items/21
			98 link Description: Edit, Value: localhost:3000/admin/footer_items/21/edit
			99 link Description: Delete, Value: localhost:3000/admin/footer_items/21/delete
		100 text Where Paul Lives 3 /live
		101 container
			102 link Description: View, Value: localhost:3000/admin/footer_items/3
			103 link Description: Edit, Value: localhost:3000/admin/footer_items/3/edit
			104 link Description: Delete, Value: localhost:3000/admin/footer_items/3/delete
	105 link Description: New Footer Item, Value: localhost:3000/admin/footer_items/new
	106 container Pagination
		107 content list
			108 text Page 1 of 1
			109 link Description: First, Value: localhost:3000/admin/footer_items?page=1
			110 link Description: Previous, Value: localhost:3000/admin/footer_items
			111 link Description: Next, Value: localhost:3000/admin/footer_items
			112 link Description: Last, Value: localhost:3000/admin/footer_items?page=1
	113 container
```

### 13-footer-items-edit

Interaction: Click first row Edit

Route: `http://localhost:3000/admin/footer_items/15/edit`

[Screenshot](screenshots/13-footer-items-edit.jpg)

```text
	15 container
		16 heading Edit Footer Item, Value: 1
			17 text Edit Footer Item
		18 text Label*
		19 text field (settable) Label*, Value: Admin Dashboard, ID: footer_item_label
		20 text Icon
		21 text field (settable) Icon, Value: /images/gear.svg, ID: footer_item_icon
		22 text Options
		23 text field (settable) Options, ID: footer_item_options
		24 text Link
		25 text field (settable) Link, Value: /admin, ID: footer_item_link
		26 text Access
		27 text field (settable) Access, ID: footer_item_access
		28 text Footer Order*
		29 stepper (settable, integer) Value: 16, ID: footer-order-field
		30 text Parent footer
		31 pop up button (collapsed, settable) Parent footer, Value: OTHER, ID: footer_item_parent_id, Secondary Actions: Expand
			32 menu
				33 PROFESSIONAL
				34 Professional Overview
				36 Search Website
				37 Contact Paul
				38 Login
				39 PERSONAL
				40 Admin Dashboard
				41 Blog
				42 Blog
				43 Biography
				44 Employment History
				45 Paul's Family
				46 Hobbies and Activities
				47 Where Paul Lives
				48 Portfolio
				49 Test Page
		50 text * - Required Fields
		51 button Save Footer Item
		52 link Description: Cancel, Value: localhost:3000/admin/footer_items
	53 container
```

### 14-footer-items-new

Interaction: Cancel Edit; click New Footer Item

Route: `http://localhost:3000/admin/footer_items/new`

[Screenshot](screenshots/14-footer-items-new.jpg)

```text
	15 container
		16 heading New Footer Item, Value: 1
			17 text New Footer Item
		18 text Label*
		19 text field (settable) Label*, ID: footer_item_label
		20 text Icon
		21 text field (settable) Icon, ID: footer_item_icon
		22 text Options
		23 text field (settable) Options, ID: footer_item_options
		24 text Link
		25 text field (settable) Link, ID: footer_item_link
		26 text Access
		27 text field (settable) Access, ID: footer_item_access
		28 text Footer Order*
		29 stepper (settable) footer-order-field
		30 text Parent footer
		31 pop up button (collapsed, settable) Parent footer, ID: footer_item_parent_id, Secondary Actions: Expand
			32 menu
				34 PROFESSIONAL
				35 Professional Overview
				36 OTHER
				37 Search Website
				38 Contact Paul
				39 Login
				40 PERSONAL
				41 Admin Dashboard
				42 Blog
				43 Blog
				44 Biography
				45 Employment History
				46 Paul's Family
				47 Hobbies and Activities
				48 Where Paul Lives
				49 Portfolio
				50 Test Page
		51 text * - Required Fields
		52 button Save Footer Item
		53 link Description: Cancel, Value: localhost:3000/admin/footer_items
	54 container
```

### 15-pages-list

Interaction: Click Pages

Route: `http://localhost:3000/admin/pages`

[Screenshot](screenshots/15-pages-list.jpg)

```text
	15 link Description: Name ↓↑, Value: localhost:3000/admin/pages?direction=asc&sort=name
	16 link Description: Section ↓↑, Value: localhost:3000/admin/pages?direction=asc&sort=section
	17 link Description: Title ↓↑, Value: localhost:3000/admin/pages?direction=asc&sort=title
	18 link Description: Access ↓↑, Value: localhost:3000/admin/pages?direction=asc&sort=access
	19 link Description: Clear Sort, Value: localhost:3000/admin/pages#
	20 container
		21 text bio Bio Paul's Mini-Biography
		22 container
			23 link Description: View, Value: localhost:3000/admin/pages/1
			24 link Description: Edit, Value: localhost:3000/admin/pages/1/edit
			25 link Description: Delete, Value: localhost:3000/admin/pages/1/delete
		26 text blog Blog Paul's Blog
		27 container
			28 link Description: View, Value: localhost:3000/admin/pages/2
			29 link Description: Edit, Value: localhost:3000/admin/pages/2/edit
			30 link Description: Delete, Value: localhost:3000/admin/pages/2/delete
		31 text employment Employment Pau's Employment
		32 container
			33 link Description: View, Value: localhost:3000/admin/pages/3
			34 link Description: Edit, Value: localhost:3000/admin/pages/3/edit
			35 link Description: Delete, Value: localhost:3000/admin/pages/3/delete
		36 text family Family Paul's Family
		37 container
			38 link Description: View, Value: localhost:3000/admin/pages/4
			39 link Description: Edit, Value: localhost:3000/admin/pages/4/edit
			40 link Description: Delete, Value: localhost:3000/admin/pages/4/delete
		41 text hobby Hobby Hobbies and Activities
		42 container
			43 link Description: View, Value: localhost:3000/admin/pages/5
			44 link Description: Edit, Value: localhost:3000/admin/pages/5/edit
			45 link Description: Delete, Value: localhost:3000/admin/pages/5/delete
		46 text home Home Home Page
		47 container
			48 link Description: View, Value: localhost:3000/admin/pages/6
			49 link Description: Edit, Value: localhost:3000/admin/pages/6/edit
			50 link Description: Delete, Value: localhost:3000/admin/pages/6/delete
		51 text live Live Where Paul Lives
		52 container
			53 link Description: View, Value: localhost:3000/admin/pages/7
			54 link Description: Edit, Value: localhost:3000/admin/pages/7/edit
			55 link Description: Delete, Value: localhost:3000/admin/pages/7/delete
		56 text overview Overview overview
		57 container
			58 link Description: View, Value: localhost:3000/admin/pages/77
			59 link Description: Edit, Value: localhost:3000/admin/pages/77/edit
			60 link Description: Delete, Value: localhost:3000/admin/pages/77/delete
		61 text portfolio Portfolio Paul's Portfolio
		62 container
			63 link Description: View, Value: localhost:3000/admin/pages/9
			64 link Description: Edit, Value: localhost:3000/admin/pages/9/edit
			65 link Description: Delete, Value: localhost:3000/admin/pages/9/delete
		66 text test-page test-page Test Page
		67 container
			68 link Description: View, Value: localhost:3000/admin/pages/76
			69 link Description: Edit, Value: localhost:3000/admin/pages/76/edit
			70 link Description: Delete, Value: localhost:3000/admin/pages/76/delete
		71 link Description: New page, Value: localhost:3000/admin/pages/new
		72 container Pagination
			73 content list
				74 text Page 1 of 1
				75 link Description: First, Value: localhost:3000/admin/pages?page=1
				76 link Description: Previous, Value: localhost:3000/admin/pages
				77 link Description: Next, Value: localhost:3000/admin/pages
				78 link Description: Last, Value: localhost:3000/admin/pages?page=1
	79 container
```

### 16-pages-edit

Interaction: Click first row Edit

Route: `http://localhost:3000/admin/pages/1/edit`

[Screenshot](screenshots/16-pages-edit.jpg)

```text
	15 container
		16 heading Edit Page, Value: 1
			17 text Edit Page
		18 text Name*
		19 text field (settable) Name*, Value: bio, ID: page_name
		20 text Section
		21 text field (settable) Section, Value: Bio, ID: page_section
		22 text Title
		23 text field (settable) Title, Value: Paul's Mini-Biography, ID: page_title
		24 text Access
		25 text field (settable) Access, ID: page_access
		26 heading Preview, Value: 1
			27 text Preview
		28 container bio
			29 container
				30 link Description: Edit Section, Value: localhost:3000/admin/sections/47/edit?cancel_url=%2Fadmin%2Fpages%2F1%2Fedit%3Fsection_name%3Dbio%26target%3D_self&new_section=false&read_only_content_type=true&return_url=%2Fadmin%2Fpages%2F1%2Fedit%3Fsection_name%3Dbio%26target%3D_self&target=_self
				31 link Description: Delete Section, Value: localhost:3000/admin/sections/47?method=delete&return_url=%2Fadmin%2Fpages%2F1%2Fedit%3Fsection_name%3Dbio%26target%3D_self
			32 container bio
				33 link Description: Edit Column, Value: localhost:3000/admin/cells/63/edit
				34 link Description: Delete Column, Value: localhost:3000/admin/cells/63
				35 container contents
					36 text Paul was born at Queen of Angels Hospital in Los Angeles, CA, and spent his early years in Panorama City in the San Fernando Valley. At 8, his family moved to Newhall, CA (now Santa Clarita), where he lived until his 30s before heading up to Washington state.
					37 text Paul became a Christian at 14 after reading The Late Great Planet Earth, and he got involved with several churches, including Agape, a "Jesus People" church. With a couple of friends, he formed a small vocal group, performing at various churches. When he turned 18, he went on to attend Biola College.
					38 text He met his wife, Virginia, when he was 16. They didn’t fall in love right away but quickly became best friends, staying close for seven years before getting married. Paul loves music, and he and Virginia even played in a band together called Born Again, with him on guitar and vocals and Virginia singing. Virginia’s daughter, Joy, was nine months old when they got married, and Paul loved being a dad. They sang to each other at their wedding, and not long after, they moved to Washington. A year later, they welcomed their son, Jonathan.
					39 text Jonathan had a challenging start in life—he was diagnosed with a heart defect (aortic stenosis) at just over a month old, requiring open-heart surgery. Over the years, he’s been through two heart surgeries, including a valve replacement and pacemaker implant at 14. Despite a few close calls, Jon’s resilience shines through. In 1998, the family moved to Orcas Island, which has been home ever since.
					40 text Paul’s daughter, Joy, now has three children: Brandon, Kevin, and Jessica. They all live together on Orcas Island, making it a true extended family home.
					41 container
						42 text Originally planning to study psychology, Paul switched to computer science after his parents gifted him a computer. After graduating, he launched a career as a software engineer, working for various companies. A highlight was joining 
						43 link Description: Amazon.com, Value: localhost:3000/employment?section_name=amazon
						44 text  in its early startup days, where he played a key role in developing their shipping software, boosting performance by 85%.
					45 text Today, Paul, Virginia, Joy, Jon, and Brandon, Kevin, and Jessica are happily settled on Orcas Island, enjoying life together as one big family.
		46 link Description: Add Section, Value: localhost:3000/admin/page/new_section/1?cancel_url=%2Fadmin%2Fpages%2F1%2Fedit%3Fsection_name%3Dbio%26target%3D_self&new_section=true&read_only_content_type=true&return_url=%2Fadmin%2Fpages%2F1%2Fedit%3Fsection_name%3Dbio%26target%3D_self
		47 text * - Required Fields
		48 button Save Page
		49 link Description: Cancel, Value: localhost:3000/admin/pages
	50 container
```

### 17-pages-new

Interaction: Cancel Edit; click New page

Route: `http://localhost:3000/admin/pages/new`

[Screenshot](screenshots/17-pages-new.jpg)

```text
	15 container
		16 text Page Title:
		17 text field (settable) title
		18 text Page Name*:
		19 text field (settable) name
		20 text Section Group*:
		21 text field (settable) section
		22 text Page Access:
		23 text field (settable) access
		24 heading Preview, Value: 1
			25 text Preview
		26 heading No Contents, Value: 2
			27 text No Contents
	28 container
```

### 18-sections-list

Interaction: Click Sections

Route: `http://localhost:3000/admin/sections`

[Screenshot](screenshots/18-sections-list.jpg)

```text
	15 heading Section, Value: 2
		16 text Section
	17 container
		18 link Description: Clear Sort, Value: localhost:3000/admin/sections?clear_sort=true
		19 link Description: View, Value: localhost:3000/admin/sections/152
		20 link Description: Edit, Value: localhost:3000/admin/sections/152/edit
		21 link Description: Delete, Value: localhost:3000/admin/sections/152/delete
	22 container Pagination
		23 content list
			24 link Description: First, Value: localhost:3000/admin/sections?page=1
			25 link Description: Previous, Value: localhost:3000/admin/sections
			26 link Description: Next, Value: localhost:3000/admin/sections?page=2
			27 link Description: Last, Value: localhost:3000/admin/sections?page=65
	28 link Description: Type ↓↑, Value: localhost:3000/admin/sections?direction=asc&sort=content_type
	29 link Description: Name ↓↑, Value: localhost:3000/admin/sections?direction=asc&sort=section_name
	30 link Description: Order: ↓↑, Value: localhost:3000/admin/sections?direction=asc&sort=section_order
	31 link Description: Image: ↓↑, Value: localhost:3000/admin/sections?direction=asc&sort=image
	32 link Description: URL: ↓↑, Value: localhost:3000/admin/sections?direction=asc&sort=link
	33 text bio
	34 text legacy-test-1790710784
	35 text 999
	36 container Pagination
		37 content list
			38 text Page 1 of 65
			39 link Description: First, Value: localhost:3000/admin/sections?page=1
			40 link Description: Previous, Value: localhost:3000/admin/sections
			41 link Description: Next, Value: localhost:3000/admin/sections?page=2
			42 link Description: Last, Value: localhost:3000/admin/sections?page=65
	43 container sections_search_form
		44 text Content Type
		45 search text field (settable) Content Type, ID: q_content_type_cont
		46 text Section Name
		47 search text field (settable) Section Name, ID: q_section_name_cont
		48 text Image
		49 search text field (settable) Image, ID: q_image_cont
		50 text URL
		51 search text field (settable) URL, ID: q_link_cont
		52 text Description
		53 search text field (settable) Description, ID: q_description_cont
		54 container
			55 button Search Sections
			56 link Description: Clear Search, Value: localhost:3000/admin/sections?clear_search=true
	57 container
```

### 19-sections-edit

Interaction: Click first row Edit

Route: `http://localhost:3000/admin/sections/152/edit`

[Screenshot](screenshots/19-sections-edit.jpg)

```text
	15 container GenerateCells
		16 text Templates:
		17 pop up button (collapsed, settable) Value: Select an option, ID: cellTemplates, Secondary Actions: Expand
			18 menu
				20 Text Only
				21 Image Only
				22 Dual Column - Text Left
				23 Dual Column - Text Right
				24 Three Column
				25 Four Column
				26 Five Column
		27 button Generate Columns
	28 container
```

### 20-cells-list

Interaction: Click Cells

Route: `http://localhost:3000/admin/cells`

[Screenshot](screenshots/20-cells-list.jpg)

```text
	15 heading Cell, Value: 2
		16 text Cell
	17 container
		18 link Description: Clear Sort, Value: localhost:3000/admin/cells?clear_sort=true
		19 link Description: View, Value: localhost:3000/admin/cells/188
		20 link Description: Edit, Value: localhost:3000/admin/cells/188/edit
		21 link Description: Delete, Value: localhost:3000/admin/cells/188/delete
	22 container Pagination
		23 content list
			24 link Description: First, Value: localhost:3000/admin/cells?page=1
			25 link Description: Previous, Value: localhost:3000/admin/cells
			26 link Description: Next, Value: localhost:3000/admin/cells?page=2
			27 link Description: Last, Value: localhost:3000/admin/cells?page=124
	28 text Text for Fourth Cell.
	29 link Description: Section ↓↑, Value: localhost:3000/admin/cells?direction=asc&sort=section_name
	30 link Description: Name ↓↑, Value: localhost:3000/admin/cells?direction=asc&sort=cell_name
	31 link Description: Order: ↓↑, Value: localhost:3000/admin/cells?direction=asc&sort=cell_order
	32 link Description: Image: ↓↑, Value: localhost:3000/admin/cells?direction=asc&sort=image
	33 link Description: Type: ↓↑, Value: localhost:3000/admin/cells?direction=asc&sort=cell_type
	34 text test-section
	35 text test-section-4
	36 text 4
	37 text text
	38 container Pagination
		39 content list
			40 text Page 1 of 124
			41 link Description: First, Value: localhost:3000/admin/cells?page=1
			42 link Description: Previous, Value: localhost:3000/admin/cells
			43 link Description: Next, Value: localhost:3000/admin/cells?page=2
			44 link Description: Last, Value: localhost:3000/admin/cells?page=124
	45 container cells_search_form
		46 text Section Name
		47 search text field (settable) Section Name, ID: q_section_name_cont
		48 text Cell Name
		49 search text field (settable) Cell Name, ID: q_cell_name_cont
		50 text Image
		51 search text field (settable) Image, ID: q_image_cont
		52 text URL
		53 search text field (settable) URL, ID: q_link_cont
		54 text Content
		55 search text field (settable) Content, ID: q_content_cont
		56 container
			57 button Search Cells
			58 link Description: Clear Search, Value: localhost:3000/admin/cells?clear_search=true
	59 container
```

### 21-cells-edit

Interaction: Click first row Edit

Route: `http://localhost:3000/admin/cells/188/edit`

[Screenshot](screenshots/21-cells-edit.jpg)

```text
	15 container
		16 text Content Type:
		17 container
			18 container
				19 text test-section
				20 combo box (collapsed, settable) ID: section_name, Secondary Actions: Expand
		21 text Column Name*:
		22 text field (settable) Value: test-section-4, ID: cell_name
		23 text Content:
		24 container contentDiv
			25 container content
				26 container
					27 button (collapsed) Sans Serif, Secondary Actions: Expand
						28 text Sans Serif
						29 image
				30 container
					31 button (collapsed) Normal, Secondary Actions: Expand
						32 text Normal
						33 image
				34 container
					35 button
						36 image
					37 button
						38 image
					39 button
						40 image
					41 button
						42 image
				43 container
					44 button (collapsed) Secondary Actions: Expand
						45 image
					46 button (collapsed) Secondary Actions: Expand
						47 image
				48 container
					49 button
						50 image
					51 button
						52 image
				53 container
					54 button (collapsed) Normal, Secondary Actions: Expand
						55 text Normal
						56 image
				57 container
					58 button
						59 image
					60 button
						61 image
				62 container
					63 button (collapsed) Secondary Actions: Expand
						64 image
				65 container
					66 button
						67 image
					68 button
						69 image
					70 button
						71 image
					72 button
						73 image
				74 container
					75 button
						76 image
				77 container
					78 button <div>
				79 container
					80 container Text for Fourth Cell.
						81 text Text for Fourth Cell.
			82 button Switch to HTML View **
			83 text ** HTML View should only be used by users who are familiar with HTML
		84 text Image:
		85 container
			86 container
				87 text Select or type...
				88 combo box (collapsed, settable) ID: image, Secondary Actions: Expand
		89 pop up button (collapsed, settable) Value: Image, ID: image_type, Secondary Actions: Expand
			90 menu
				91 Select an option
				93 Image Section
				94 Image Group
				95 Video
				96 Upload
		97 text Link (URL):
		98 text field (settable) link
		99 text Column Order:
		100 stepper (settable, integer) Value: 4, ID: cell_order
		101 text Margin Top:
		102 pop up button (collapsed, settable) Value: Select an option, ID: marginTop, Secondary Actions: Expand
			103 menu
				105 None
				106 Margin Top - #1
				107 Margin Top - #2
				108 Margin Top - #3
				109 Margin Top - #4
				110 Margin Top - #5
		111 text Margin Left:
		112 pop up button (collapsed, settable) Value: Select an option, ID: marginLeft, Secondary Actions: Expand
			113 menu
				115 None
				116 Margin Left - #1
				117 Margin Left - #2
				118 Margin Left - #3
				119 Margin Left - #4
				120 Margin Left - #5
		121 text Margin Bottom:
		122 pop up button (collapsed, settable) Value: Select an option, ID: marginBottom, Secondary Actions: Expand
			123 menu
				125 None
				126 Margin Bottom - #1
				127 Margin Bottom - #2
				128 Margin Bottom - #3
				129 Margin Bottom - #4
				130 Margin Bottom - #5
		131 text Margin Right:
		132 pop up button (collapsed, settable) Value: Select an option, ID: marginRight, Secondary Actions: Expand
			133 menu
				135 None
				136 Margin Right - #1
				137 Margin Right - #2
				138 Margin Right - #3
				139 Margin Right - #4
				140 Margin Right - #5
		141 text Background Color:
		142 pop up button (collapsed, settable) Value: Select an option, ID: backgroundColor, Secondary Actions: Expand
			143 menu
				148 Red
				149 Green
				150 Blue
				151 Gray
				152 Yellow
				153 Cyan
				154 Magenta
				155 Lime
				156 Silver
				157 Maroon
				158 Olive
				159 Green
				160 Purple
				161 Teal
				162 Navy
				163 Orange
				164 Gainsboro
				165 Light Gray
				166 Dark Gray
				167 Dim Gray
				168 Slate Gray
				169 Light Slate Gray
				170 Dark Slate Gray
				171 White Smoke
				172 Light Coral
				173 Indian Red
				174 Crimson
				175 Fire Brick
				176 Dark Red
				177 Pink
				178 Light Pink
				179 Hot Pink
				180 Deep Pink
				181 Medium Violet Red
				182 Pale Violet Red
				183 Coral
				184 Tomato
				185 Orange Red
				186 Dark Orange
				187 Orange
				188 Moccasin
				189 Peach Puff
				190 Papaya Whip
				191 Saddle Brown
				192 Sienna
				193 Chocolate
				194 Peru
				195 Tan
				196 Burly Wood
				197 Wheat
				198 Gold
				199 Yellow
				200 Light Yellow
				201 Lemon Chiffon
				202 Khaki
				203 Pale Golden Rod
				204 Dark Khaki
				205 Lawn Green
				206 Chartreuse
				207 Green Yellow
				208 Lime Green
				209 Pale Green
				210 Light Green
				211 Medium Spring Green
				212 Spring Green
				213 Forest Green
				214 Sea Green
				215 Medium Sea Green
				216 Dark Sea Green
				217 Olive Drab
				218 Dark Olive Green
				219 Dark Green
				220 Light Cyan
				221 Pale Turquoise
				222 Aquamarine
				223 Medium Aquamarine
				224 Turquoise
				225 Medium Turquoise
				226 Dark Turquoise
				227 Light Sea Green
				228 Cadet Blue
				229 Dark Cyan
				230 Light Blue
				231 Powder Blue
				232 Sky Blue
				233 Light Sky Blue
				234 Deep Sky Blue
				235 Dodger Blue
				236 Cornflower Blue
				237 Royal Blue
				238 Medium Blue
				239 Dark Blue
				240 Midnight Blue
				241 Lavender
				242 Thistle
				243 Plum
				244 Violet
				245 Orchid
				246 Medium Orchid
				247 Dark Orchid
				248 Dark Violet
				249 Blue Violet
				250 Medium Purple
				251 Slate Blue
				252 Medium Slate Blue
				253 Dark Slate Blue
				254 Snow
				255 Honey Dew
				256 Mint Cream
				257 Azure
				258 Alice Blue
				259 Ghost White
				260 Floral White
				261 Old Lace
				262 Ivory
				263 Seashell
				264 Beige
				265 Linen
				266 Antique White
				267 Dark Slate Gray
				268 Dim Gray
				269 Slate Gray
		270 button Switch to Formatting Mode **
		271 text ** Formatting mode should only be used by users who are familiar with CSS
		272 text * - Required Fields
		273 text Text for Fourth Cell.
		274 button Save Column
		275 button Cancel
	276 container
```

### 22-image-files-list

Interaction: Click Image Files

Route: `http://localhost:3000/admin/image_files`

[Screenshot](screenshots/22-image-files-list.jpg)

```text
	15 text Preview
	16 link Description: Name ↓↑, Value: localhost:3000/admin/image_files?direction=asc&sort=name
	17 link Description: Group ↓↑, Value: localhost:3000/admin/image_files?direction=asc&sort=group
	18 link Description: Clear Sort, Value: localhost:3000/admin/image_files#
	19 container Pagination
		20 content list
			21 link Description: First, Value: localhost:3000/admin/image_files?page=1
			22 link Description: Previous, Value: localhost:3000/admin/image_files
			23 link Description: Next, Value: localhost:3000/admin/image_files?page=2
			24 link Description: Last, Value: localhost:3000/admin/image_files?page=46
	25 container
		26 link localhost:3000/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsiZGF0YSI6MTk5LCJwdXIiOiJibG9iX2lkIn19--2eb8fb9e885671280f06ed7acd485b8c0c17efb9/nava-logo.jpg
		27 text nava-logo
		28 button Add Group
		29 container
			30 link Description: View, Value: localhost:3000/admin/image_files/185
			31 link Description: Edit, Value: localhost:3000/admin/image_files/185/edit
			32 link Description: Delete, Value: localhost:3000/admin/image_files/185/delete
		33 heading JumpStartServer.com, Value: 2
			34 text JumpStartServer.com
		35 container contents
			36 link localhost:3000/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsiZGF0YSI6MTk4LCJwdXIiOiJibG9iX2lkIn19--62741cd791c711ccfc207d060d048bdbb96900f7/JumpStartWebsite.jpg
			37 content list
				38 container
					39 AXListMarker • 
					40 text Rails 8.0, Ruby 3.2, React 18.3.1, PostgresSQL 15.8, Node 23.2.0, Debian Linux 12, Bootstrap 5.3.3
				41 container
					42 AXListMarker • 
					43 text Devise used for user validation.
				44 container
					45 AXListMarker • 
					46 text Ransack used for search.
				47 container
					48 AXListMarker • 
					49 text Nokogiri used for html parsing and sanitization.
				50 container
					51 AXListMarker • 
					52 text Recaptcha used for SPAM prevention.
				53 container
					54 AXListMarker • 
					55 text Fully reactive UI. It works on everything from an iPhone (or other mobile device) all the way up to the largest desktop display and everything in between.
				56 container
					57 AXListMarker • 
					58 text Database driven UI (no coding changes needed to alter the UI).
				59 container
					60 AXListMarker • 
					61 text Minimalist UI. It uses expandable / collapsable sections to not overwhelm the user.
			62 container
				63 text You can see the code at 
				64 link Description: https://github.com/PaulCarrick/jump-start-website, Value: github.com/PaulCarrick/jump-start-website
		65 content list
			66 container
				67 AXListMarker • 
				68 text Rails 8.0, Ruby 3.2, React 18.3.1, PostgresSQL 15.8, Node 23.2.0, Debian Linux 12, Bootstrap 5.3.3
			69 container
				70 AXListMarker • 
				71 text Devise used for user validation.
			72 container
				73 AXListMarker • 
				74 text Ransack used for search.
			75 container
				76 AXListMarker • 
				77 text Nokogiri used for html parsing and sanitization.
			78 container
				79 AXListMarker • 
				80 text Recaptcha used for SPAM prevention.
			81 container
				82 AXListMarker • 
				83 text Fully reactive UI. It works on everything from an iPhone (or other mobile device) all the way up to the largest desktop display and everything in between.
			84 container
				85 AXListMarker • 
				86 text Database driven UI (no coding changes needed to alter the UI).
			87 container
				88 AXListMarker • 
				89 text Minimalist UI. It uses expandable / collapsable sections to not overwhelm the user.
		90 text You can see the code at 
		91 link Description: https://github.com/PaulCarrick/jump-start-website, Value: github.com/PaulCarrick/jump-start-website
		92 text jumpstartserver.com
		93 button Add Group
		94 container
			95 link Description: View, Value: localhost:3000/admin/image_files/184
			96 link Description: Edit, Value: localhost:3000/admin/image_files/184/edit
			97 link Description: Delete, Value: localhost:3000/admin/image_files/184/delete
		98 text Paul and Virginia Diving a Shipwreck the USS Kittiwake.
		99 container videoElement
			100 container buffering
			101 container
				102 button
				103 pop up button
			104 slider (disabled) video time scrubber
		105 text This is a video of Paul and Virginia diving a shipwreck the USS Kittiwake. shipwreck - movie
		106 button Add Group
		107 container
			108 link Description: View, Value: localhost:3000/admin/image_files/182
			109 link Description: Edit, Value: localhost:3000/admin/image_files/182/edit
			110 link Description: Delete, Value: localhost:3000/admin/image_files/182/delete
		111 link localhost:3000/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsiZGF0YSI6MTk1LCJwdXIiOiJibG9iX2lkIn19--03434412ddf07ae1d361065a00fe5b14d93692b1/shipwreck.mp4
		112 text shipw
		113 button Add Group
		114 container
			115 link Description: View, Value: localhost:3000/admin/image_files/181
			116 link Description: Edit, Value: localhost:3000/admin/image_files/181/edit
			117 link Description: Delete, Value: localhost:3000/admin/image_files/181/delete
		118 link Description: New Image, Value: localhost:3000/admin/image_files/new
		119 container Pagination
			120 content list
				121 text Page 1 of 46
				122 link Description: First, Value: localhost:3000/admin/image_files?page=1
				123 link Description: Previous, Value: localhost:3000/admin/image_files
				124 link Description: Next, Value: localhost:3000/admin/image_files?page=2
				125 link Description: Last, Value: localhost:3000/admin/image_files?page=46
	126 container image_file_search
		127 text Name
		128 search text field (settable) Name, ID: q_name_cont
		129 text Group
		130 search text field (settable) Group, ID: q_group_cont
		131 text Caption
		132 search text field (settable) Caption, ID: q_caption_cont
		133 text Description
		134 search text field (settable) Description, ID: q_description_cont
		135 container
			136 button Search Images
			137 link Description: Clear Search, Value: localhost:3000/admin/image_files?clear_search=true
	138 container
```

### 23-image-files-edit

Interaction: Click first row Edit

Route: `http://localhost:3000/admin/image_files/185/edit`

[Screenshot](screenshots/23-image-files-edit.jpg)

```text
	15 container
		16 text Name*
		17 text field Name*, Value: nava-logo, ID: image_file_name
		18 text Upload Image*
		19 button Upload Image*, ID: image_file_image
		20 text Mime Type
		21 pop up button (collapsed, settable) Mime Type, Value: PNG, ID: image_file_mime_type, Secondary Actions: Expand
			22 menu
				23 JPEG
				25 GIF
				26 BMP
				27 WebP
				28 SVG
				29 TIFF
				30 ICO
				31 HEIC
				32 MP4
		33 text Group
		34 text field (settable) group-field
		35 button Add to Group, ID: add-to-group-btn
		36 text Slide Order
		37 stepper (settable) slide-order-field
		38 text Caption
		39 container image-file-caption
			40 container
				41 button (collapsed) Sans Serif, Secondary Actions: Expand
					42 text Sans Serif
					43 image
			44 container
				45 button (collapsed) Normal, Secondary Actions: Expand
					46 text Normal
					47 image
			48 container
				49 button
					50 image
				51 button
					52 image
				53 button
					54 image
				55 button
					56 image
			57 container
				58 button (collapsed) Secondary Actions: Expand
					59 image
				60 button (collapsed) Secondary Actions: Expand
					61 image
			62 container
				63 button
					64 image
				65 button
					66 image
			67 container
				68 button (collapsed) Normal, Secondary Actions: Expand
					69 text Normal
					70 image
			71 container
				72 button
					73 image
				74 button
					75 image
			76 container
				77 button (collapsed) Secondary Actions: Expand
					78 image
			79 container
				80 button
					81 image
				82 button
					83 image
				84 button
					85 image
				86 button
					87 image
			88 container
				89 button
					90 image
			91 container
				92 button <div>
			93 container
				94 container 

					95 text Enter the caption for the image...
		96 text Description
		97 container image-file-description
			98 container
				99 button (collapsed) Sans Serif, Secondary Actions: Expand
					100 text Sans Serif
					101 image
			102 container
				103 button (collapsed) Normal, Secondary Actions: Expand
					104 text Normal
					105 image
			106 container
				107 button
					108 image
				109 button
					110 image
				111 button
					112 image
				113 button
					114 image
			115 container
				116 button (collapsed) Secondary Actions: Expand
					117 image
				118 button (collapsed) Secondary Actions: Expand
					119 image
			120 container
				121 button
					122 image
				123 button
					124 image
			125 container
				126 button (collapsed) Normal, Secondary Actions: Expand
					127 text Normal
					128 image
			129 container
				130 button
					131 image
				132 button
					133 image
			134 container
				135 button (collapsed) Secondary Actions: Expand
					136 image
			137 container
				138 button
					139 image
				140 button
					141 image
				142 button
					143 image
				144 button
					145 image
			146 container
				147 button
					148 image
			149 container
				150 button <div>
			151 container
				152 container 

					153 text Enter the description for the image...
		154 button Switch to HTML View **
		155 text ** HTML View should only be used by users who are familiar with HTML
		156 button Save Image
		157 link Description: Cancel, Value: localhost:3000/admin/image_files
	158 container
```

### 24-image-files-new

Interaction: Cancel Edit; click New Image

Route: `http://localhost:3000/admin/image_files/new`

[Screenshot](screenshots/24-image-files-new.jpg)

```text
	15 container
		16 text Name*
		17 text field (settable) Name*, ID: image_file_name
		18 text Upload Image*
		19 button Upload Image*, ID: image_file_image
		20 text Mime Type
		21 pop up button (collapsed, settable) Mime Type, ID: image_file_mime_type, Secondary Actions: Expand
			22 menu
				24 JPEG
				25 PNG
				26 GIF
				27 BMP
				28 WebP
				29 SVG
				30 TIFF
				31 ICO
				32 HEIC
				33 MP4
		34 text Group
		35 text field (settable) group-field
		36 button Add to Group, ID: add-to-group-btn
		37 text Slide Order
		38 stepper (settable) slide-order-field
		39 text Caption
		40 container image-file-caption
			41 container
				42 button (collapsed) Sans Serif, Secondary Actions: Expand
					43 text Sans Serif
					44 image
			45 container
				46 button (collapsed) Normal, Secondary Actions: Expand
					47 text Normal
					48 image
			49 container
				50 button
					51 image
				52 button
					53 image
				54 button
					55 image
				56 button
					57 image
			58 container
				59 button (collapsed) Secondary Actions: Expand
					60 image
				61 button (collapsed) Secondary Actions: Expand
					62 image
			63 container
				64 button
					65 image
				66 button
					67 image
			68 container
				69 button (collapsed) Normal, Secondary Actions: Expand
					70 text Normal
					71 image
			72 container
				73 button
					74 image
				75 button
					76 image
			77 container
				78 button (collapsed) Secondary Actions: Expand
					79 image
			80 container
				81 button
					82 image
				83 button
					84 image
				85 button
					86 image
				87 button
					88 image
			89 container
				90 button
					91 image
			92 container
				93 button <div>
			94 container
				95 container 

					96 text Enter the caption for the image...
		97 text Description
		98 container image-file-description
			99 container
				100 button (collapsed) Sans Serif, Secondary Actions: Expand
					101 text Sans Serif
					102 image
			103 container
				104 button (collapsed) Normal, Secondary Actions: Expand
					105 text Normal
					106 image
			107 container
				108 button
					109 image
				110 button
					111 image
				112 button
					113 image
				114 button
					115 image
			116 container
				117 button (collapsed) Secondary Actions: Expand
					118 image
				119 button (collapsed) Secondary Actions: Expand
					120 image
			121 container
				122 button
					123 image
				124 button
					125 image
			126 container
				127 button (collapsed) Normal, Secondary Actions: Expand
					128 text Normal
					129 image
			130 container
				131 button
					132 image
				133 button
					134 image
			135 container
				136 button (collapsed) Secondary Actions: Expand
					137 image
			138 container
				139 button
					140 image
				141 button
					142 image
				143 button
					144 image
				145 button
					146 image
			147 container
				148 button
					149 image
			150 container
				151 button <div>
			152 container
				153 container 

					154 text Enter the description for the image...
		155 button Switch to HTML View **
		156 text ** HTML View should only be used by users who are familiar with HTML
		157 button Save Image
		158 link Description: Cancel, Value: localhost:3000/admin/image_files
	159 container
```

### 25-image-files-html

Interaction: Switch New Image editors to HTML View; no content entered

Route: `http://localhost:3000/admin/image_files/new`

[Screenshot](screenshots/25-image-files-html.jpg)

```text
	15 container
		16 text Name*
		17 text field (settable) Name*, ID: image_file_name
		18 text Upload Image*
		19 button Upload Image*, ID: image_file_image
		20 text Mime Type
		21 pop up button (collapsed, settable) Mime Type, ID: image_file_mime_type, Secondary Actions: Expand
			22 menu
				24 JPEG
				25 PNG
				26 GIF
				27 BMP
				28 WebP
				29 SVG
				30 TIFF
				31 ICO
				32 HEIC
				33 MP4
		34 text Group
		35 text field (settable) group-field
		36 button Add to Group, ID: add-to-group-btn
		37 text Slide Order
		38 stepper (settable) slide-order-field
		39 text Caption
		40 container image-file-caption
			41 container
				42 button (collapsed) Sans Serif, Secondary Actions: Expand
					189 text Sans Serif
					44 image
			45 container
				46 button (collapsed) Normal, Secondary Actions: Expand
					190 text Normal
					48 image
			49 container
				50 button
					51 image
				52 button
					53 image
				54 button
					55 image
				56 button
					57 image
			58 container
				59 button (collapsed) Secondary Actions: Expand
					60 image
				61 button (collapsed) Secondary Actions: Expand
					62 image
			63 container
				64 button
					65 image
				66 button
					67 image
			68 container
				69 button (collapsed) Normal, Secondary Actions: Expand
					191 text Normal
					71 image
			72 container
				73 button
					74 image
				75 button
					76 image
			77 container
				78 button (collapsed) Secondary Actions: Expand
					79 image
			80 container
				81 button
					82 image
				83 button
					84 image
				85 button
					86 image
				87 button
					88 image
			89 container
				90 button
					91 image
			92 container
				93 button <div>
			94 container
				95 container 

					192 text Enter the caption for the image...
		97 text Description
		98 container image-file-description
			99 container
				100 button (collapsed) Sans Serif, Secondary Actions: Expand
					193 text Sans Serif
					102 image
			103 container
				104 button (collapsed) Normal, Secondary Actions: Expand
					194 text Normal
					106 image
			107 container
				108 button
					109 image
				110 button
					111 image
				112 button
					113 image
				114 button
					115 image
			116 container
				117 button (collapsed) Secondary Actions: Expand
					118 image
				119 button (collapsed) Secondary Actions: Expand
					120 image
			121 container
				122 button
					123 image
				124 button
					125 image
			126 container
				127 button (collapsed) Normal, Secondary Actions: Expand
					195 text Normal
					129 image
			130 container
				131 button
					132 image
				133 button
					134 image
			135 container
				136 button (collapsed) Secondary Actions: Expand
					137 image
			138 container
				139 button
					140 image
				141 button
					142 image
				143 button
					144 image
				145 button
					146 image
			147 container
				148 button
					149 image
			150 container
				151 button <div>
			152 container
				153 container 

					196 text Enter the description for the image...
		155 button Switch to HTML View **
		156 text ** HTML View should only be used by users who are familiar with HTML
		157 button Save Image
		158 link Description: Cancel, Value: localhost:3000/admin/image_files
	159 container
```

### 26-blogs-list

Interaction: Click Blogs

Route: `http://localhost:3000/admin/blog_posts`

[Screenshot](screenshots/26-blogs-list.jpg)

```text
	15 link Description: Author ↓↑, Value: localhost:3000/admin/blog_posts?direction=asc&sort=author
	16 link Description: Title ↓↑, Value: localhost:3000/admin/blog_posts?direction=asc&sort=title
	17 link Description: Posted ↓↑, Value: localhost:3000/admin/blog_posts?direction=asc&sort=posted
	18 text Contents
	19 link Description: Clear Sort, Value: localhost:3000/admin/blog_posts#
	20 container
		21 text Paul Carrick Switching to Quill. 2025-01-07 22:53:38 UTC I really like Quill. It's an excellent HTML Editor for React. I've replaced Trix with it.
		22 container
			23 link Description: View, Value: localhost:3000/admin/blog_posts/4
			24 link Description: Edit, Value: localhost:3000/admin/blog_posts/4/edit
			25 link Description: Delete, Value: localhost:3000/admin/blog_posts/4/delete
		26 text Paul Carrick Adding Search 2024-11-25 08:10:56 UTC I'm adding search capability to my website via Ransack.
		27 container
			28 link Description: View, Value: localhost:3000/admin/blog_posts/2
			29 link Description: Edit, Value: localhost:3000/admin/blog_posts/2/edit
			30 link Description: Delete, Value: localhost:3000/admin/blog_posts/2/delete
		31 text Paul Carrick Paul's First Entry 2024-11-21 09:38:59 UTC This is my first 
		32 text post. I've been developing this website and the blog functionality is now ready. If you are seeing this post it's working.
		33 container
			34 link Description: View, Value: localhost:3000/admin/blog_posts/1
			35 link Description: Edit, Value: localhost:3000/admin/blog_posts/1/edit
			36 link Description: Delete, Value: localhost:3000/admin/blog_posts/1/delete
	37 link Description: New Blog, Value: localhost:3000/admin/blog_posts/new
	38 container Pagination
		39 content list
			40 text Page 1 of 1
			41 link Description: First, Value: localhost:3000/admin/blog_posts?page=1
			42 link Description: Previous, Value: localhost:3000/admin/blog_posts
			43 link Description: Next, Value: localhost:3000/admin/blog_posts
			44 link Description: Last, Value: localhost:3000/admin/blog_posts?page=1
	45 container blog_post_search
		46 text Author
		47 search text field (settable) Author, ID: q_author_cont
		48 text Title
		49 search text field (settable) Title, ID: q_title_cont
		50 text Posted
		51 text field (settable) Description: Please enter the date in the format YYYY-DD-MM., ID: q_posted_date_eq
		52 text Contents
		53 search text field (settable) Contents, ID: q_content_cont
		54 container
			55 button Search Blogs
			56 link Description: Clear Search, Value: localhost:3000/admin/blog_posts?clear_search=true
	57 container
```

### 27-blogs-edit

Interaction: Click first row Edit

Route: `http://localhost:3000/admin/blog_posts/4/edit`

[Screenshot](screenshots/27-blogs-edit.jpg)

```text
	15 container
		16 heading Edit Blog Post, Value: 1
			17 text Edit Blog Post
		18 text Author*
		19 text field (settable) Author*, Value: Paul Carrick, ID: blog_post_author
		20 text Title*
		21 text field (settable) Title*, Value: Switching to Quill., ID: blog_post_title
		22 text Visibility
		23 pop up button (collapsed, settable) Visibility, Value: Public, ID: blog_post_visibility, Secondary Actions: Expand
			24 menu
				26 Private
		27 text Blog Type
		28 pop up button (collapsed, settable) Blog Type, Value: Personal, ID: blog_post_blog_type, Secondary Actions: Expand
			29 menu
				31 Professional
		32 text Post*
		33 container blog-post-content
			34 container
				35 button (collapsed) Sans Serif, Secondary Actions: Expand
					36 text Sans Serif
					37 image
			38 container
				39 button (collapsed) Normal, Secondary Actions: Expand
					40 text Normal
					41 image
			42 container
				43 button
					44 image
				45 button
					46 image
				47 button
					48 image
				49 button
					50 image
			51 container
				52 button (collapsed) Secondary Actions: Expand
					53 image
				54 button (collapsed) Secondary Actions: Expand
					55 image
			56 container
				57 button
					58 image
				59 button
					60 image
			61 container
				62 button (collapsed) Normal, Secondary Actions: Expand
					63 text Normal
					64 image
			65 container
				66 button
					67 image
				68 button
					69 image
			70 container
				71 button (collapsed) Secondary Actions: Expand
					72 image
			73 container
				74 button
					75 image
				76 button
					77 image
				78 button
					79 image
				80 button
					81 image
			82 container
				83 button
					84 image
			85 container
				86 button <div>
			87 container
				88 container I really like Quill. It's an excellent HTML Editor for React. I've replaced Trix with it.
					89 text I really like Quill. It's an excellent HTML Editor for React. I've replaced Trix with it.
		90 button Switch to HTML View **
		91 text ** HTML View should only be used by users who are familiar with HTML * - Required Fields
		92 button Save Blog Post
		93 link Description: Cancel, Value: localhost:3000/admin/blog_posts
	94 container
```

### 28-blogs-new

Interaction: Cancel Edit; click New Blog

Route: `http://localhost:3000/admin/blog_posts/new`

[Screenshot](screenshots/28-blogs-new.jpg)

```text
	15 container
		16 heading New Blog Post, Value: 1
			17 text New Blog Post
		18 text Author*
		19 text field (settable) Author*, Value: Paul Carrick, ID: blog_post_author
		20 text Title*
		21 text field (settable) Title*, ID: blog_post_title
		22 text Visibility
		23 pop up button (collapsed, settable) Visibility, Value: Public, ID: blog_post_visibility, Secondary Actions: Expand
			24 menu
				26 Private
		27 text Blog Type
		28 pop up button (collapsed, settable) Blog Type, Value: Personal, ID: blog_post_blog_type, Secondary Actions: Expand
			29 menu
				31 Professional
		32 text Post*
		33 container blog-post-content
			34 container
				35 button (collapsed) Sans Serif, Secondary Actions: Expand
					36 text Sans Serif
					37 image
			38 container
				39 button (collapsed) Normal, Secondary Actions: Expand
					40 text Normal
					41 image
			42 container
				43 button
					44 image
				45 button
					46 image
				47 button
					48 image
				49 button
					50 image
			51 container
				52 button (collapsed) Secondary Actions: Expand
					53 image
				54 button (collapsed) Secondary Actions: Expand
					55 image
			56 container
				57 button
					58 image
				59 button
					60 image
			61 container
				62 button (collapsed) Normal, Secondary Actions: Expand
					63 text Normal
					64 image
			65 container
				66 button
					67 image
				68 button
					69 image
			70 container
				71 button (collapsed) Secondary Actions: Expand
					72 image
			73 container
				74 button
					75 image
				76 button
					77 image
				78 button
					79 image
				80 button
					81 image
			82 container
				83 button
					84 image
			85 container
				86 button <div>
			87 container
				88 container 

					89 text Enter the content for the post...
		90 button Switch to HTML View **
		91 text ** HTML View should only be used by users who are familiar with HTML * - Required Fields
		92 button Save Blog Post
		93 link Description: Cancel, Value: localhost:3000/admin/blog_posts
	94 container
```

### 29-page-add-section

Interaction: Open Page Edit; click Add Section

Route: `http://localhost:3000/admin/page/new_section/1?cancel_url=%2Fadmin%2Fpages%2F1%2Fedit%3Fsection_name%3Dbio%26target%3D_self&new_section=true&read_only_content_type=true&return_url=%2Fadmin%2Fpages%2F1%2Fedit%3Fsection_name%3Dbio%26target%3D_self`

[Screenshot](screenshots/29-page-add-section.jpg)

```text
Browser tab: 1, Title: "Action Controller: Exception caught", URL: "http://localhost:3000/admin/page/new_section/1?cancel_url=%2Fadmin%2Fpages%2F1%2Fedit%3Fsection_name%3Dbio%26target%3D_self&new_section=true&read_only_content_type=true&return_url=%2Fadmin%2Fpages%2F1%2Fedit%3Fsection_name%3Dbio%26target%3D_self".
1 AXWebArea Action Controller: Exception caught, URL: localhost:3000/admin/page/new_section/1?cancel_url=%2Fadmin%2Fpages%2F1%2Fedit%3Fsection_name%3Dbio%26target%3D_self&new_section=true&read_only_content_type=true&return_url=%2Fadmin%2Fpages%2F1%2Fedit%3Fsection_name%3Dbio%26target%3D_self
	2 heading ActiveRecord::RecordInvalid in Admin::PagesController#add_section_to_page, Value: 1
		3 text ActiveRecord::RecordInvalid in Admin::PagesController#add_section_to_page
	4 container container
		5 text Validation failed: Page must exist, Section name can't be blank
		6 container frame-source-0-16
			7 container
				8 text Extracted source (around line  #69 ):
			9 container
				10 container 67 68 69 70 71 72 
					11 container
						12 text 67 68 69 70 71 72
				13 container  section_order = page.sections.maximum(:section_order).to_i + 1 section_order = 1 unless section_order.present? section = Section .create! (content_type: page.section, description: "New Section. Please replace this text.", section_order: section_order) @new_section = true @read_only_content_type = true 
					14 text     section_order           = page.sections.maximum(:section_order).to_i + 1

					15 text     section_order           = 1 unless section_order.present?

					16 container
						17 text     section                 = Section .create! (content_type: page.section, description: "New Section. Please replace this text.", section_order: section_order)

					18 text     @new_section            = true

					19 text     @read_only_content_type = true

		20 text Rails.root: /Users/paul/src/jump-start-website
		21 container traces-0
			22 link Description: Application Trace, Value: localhost:3000/admin/page/new_section/1?cancel_url=%2Fadmin%2Fpages%2F1%2Fedit%3Fsection_name%3Dbio%26target%3D_self&new_section=true&read_only_content_type=true&return_url=%2Fadmin%2Fpages%2F1%2Fedit%3Fsection_name%3Dbio%26target%3D_self#
			23 text  | 
			24 link Description: Framework Trace, Value: localhost:3000/admin/page/new_section/1?cancel_url=%2Fadmin%2Fpages%2F1%2Fedit%3Fsection_name%3Dbio%26target%3D_self&new_section=true&read_only_content_type=true&return_url=%2Fadmin%2Fpages%2F1%2Fedit%3Fsection_name%3Dbio%26target%3D_self#
			25 text  | 
			26 link Description: Full Trace, Value: localhost:3000/admin/page/new_section/1?cancel_url=%2Fadmin%2Fpages%2F1%2Fedit%3Fsection_name%3Dbio%26target%3D_self&new_section=true&read_only_content_type=true&return_url=%2Fadmin%2Fpages%2F1%2Fedit%3Fsection_name%3Dbio%26target%3D_self#
			27 container
				28 link Description: app/controllers/admin/pages_controller.rb:69:in `add_section_to_page', Value: localhost:3000/admin/page/new_section/1?cancel_url=%2Fadmin%2Fpages%2F1%2Fedit%3Fsection_name%3Dbio%26target%3D_self&new_section=true&read_only_content_type=true&return_url=%2Fadmin%2Fpages%2F1%2Fedit%3Fsection_name%3Dbio%26target%3D_self#
		29 heading Request, Value: 2
			30 text Request
		31 container
			32 text Parameters :
		33 text {"cancel_url"=>"/admin/pages/1/edit?section_name=bio&target=_self",
 "new_section"=>"true",
 "read_only_content_type"=>"true",
 "return_url"=>"/admin/pages/1/edit?section_name=bio&target=_self",
 "id"=>"1"}

		34 link Description: Toggle session dump, Value: localhost:3000/admin/page/new_section/1?cancel_url=%2Fadmin%2Fpages%2F1%2Fedit%3Fsection_name%3Dbio%26target%3D_self&new_section=true&read_only_content_type=true&return_url=%2Fadmin%2Fpages%2F1%2Fedit%3Fsection_name%3Dbio%26target%3D_self#
		35 link Description: Toggle env dump, Value: localhost:3000/admin/page/new_section/1?cancel_url=%2Fadmin%2Fpages%2F1%2Fedit%3Fsection_name%3Dbio%26target%3D_self&new_section=true&read_only_content_type=true&return_url=%2Fadmin%2Fpages%2F1%2Fedit%3Fsection_name%3Dbio%26target%3D_self#
		36 heading Response, Value: 2
			37 text Response
		38 container
			39 text Headers :
		40 text None
	41 container console
		42 container
			43 text x
			44 text >> 
		45 text field (settable)

The focused UI element is 1 AXWebArea Action Controller: Exception caught, URL: localhost:3000/admin/page/new_section/1?cancel_url=%2Fadmin%2Fpages%2F1%2Fedit%3Fsection_name%3Dbio%26target%3D_self&new_section=true&read_only_content_type=true&return_url=%2Fadmin%2Fpages%2F1%2Fedit%3Fsection_name%3Dbio%26target%3D_self
```

### 30-page-edit-section

Interaction: Click Edit Section inside Page preview

Route: `http://localhost:3000/admin/sections/47/edit?cancel_url=%2Fadmin%2Fpages%2F1%2Fedit%3Fsection_name%3Dbio%26target%3D_self&new_section=false&read_only_content_type=true&return_url=%2Fadmin%2Fpages%2F1%2Fedit%3Fsection_name%3Dbio%26target%3D_self&target=_self`

[Screenshot](screenshots/30-page-edit-section.jpg)

```text
	15 container
		16 text Content Type:
		17 container
			18 container
				19 text bio
				20 combo box (collapsed, settable) ID: section_name, Secondary Actions: Expand
		21 text Section Order:
		22 stepper (settable, integer) Value: 1, ID: section_order
		23 container bio
			24 link Description: Edit Column, Value: localhost:3000/admin/sections/47/edit?cancel_url=%2Fadmin%2Fpages%2F1%2Fedit%3Fsection_name%3Dbio%26target%3D_self&new_section=false&read_only_content_type=true&return_url=%2Fadmin%2Fpages%2F1%2Fedit%3Fsection_name%3Dbio%26target%3D_self&target=_self#
			25 link Description: Delete Column, Value: localhost:3000/admin/sections/47/edit?cancel_url=%2Fadmin%2Fpages%2F1%2Fedit%3Fsection_name%3Dbio%26target%3D_self&new_section=false&read_only_content_type=true&return_url=%2Fadmin%2Fpages%2F1%2Fedit%3Fsection_name%3Dbio%26target%3D_self&target=_self#
			26 container contents
				27 text Paul was born at Queen of Angels Hospital in Los Angeles, CA, and spent his early years in Panorama City in the San Fernando Valley. At 8, his family moved to Newhall, CA (now Santa Clarita), where he lived until his 30s before heading up to Washington state.
				28 text Paul became a Christian at 14 after reading The Late Great Planet Earth, and he got involved with several churches, including Agape, a "Jesus People" church. With a couple of friends, he formed a small vocal group, performing at various churches. When he turned 18, he went on to attend Biola College.
				29 text He met his wife, Virginia, when he was 16. They didn’t fall in love right away but quickly became best friends, staying close for seven years before getting married. Paul loves music, and he and Virginia even played in a band together called Born Again, with him on guitar and vocals and Virginia singing. Virginia’s daughter, Joy, was nine months old when they got married, and Paul loved being a dad. They sang to each other at their wedding, and not long after, they moved to Washington. A year later, they welcomed their son, Jonathan.
				30 text Jonathan had a challenging start in life—he was diagnosed with a heart defect (aortic stenosis) at just over a month old, requiring open-heart surgery. Over the years, he’s been through two heart surgeries, including a valve replacement and pacemaker implant at 14. Despite a few close calls, Jon’s resilience shines through. In 1998, the family moved to Orcas Island, which has been home ever since.
				31 text Paul’s daughter, Joy, now has three children: Brandon, Kevin, and Jessica. They all live together on Orcas Island, making it a true extended family home.
				32 container
					33 text Originally planning to study psychology, Paul switched to computer science after his parents gifted him a computer. After graduating, he launched a career as a software engineer, working for various companies. A highlight was joining 
					34 link Description: Amazon.com, Value: localhost:3000/employment?section_name=amazon
					35 text  in its early startup days, where he played a key role in developing their shipping software, boosting performance by 85%.
				36 text Today, Paul, Virginia, Joy, Jon, and Brandon, Kevin, and Jessica are happily settled on Orcas Island, enjoying life together as one big family.
		37 button Save Section
		38 button Cancel
	39 container
```

### 31-cells-html

Interaction: Click Switch to HTML View on Cell Edit

Route: `http://localhost:3000/admin/cells/188/edit`

[Screenshot](screenshots/31-cells-html.jpg)

```text
	15 container
		16 text Content Type:
		17 container
			18 container
				19 text test-section
				20 combo box (collapsed, settable) ID: section_name, Secondary Actions: Expand
		21 text Column Name*:
		22 text field (settable) Value: test-section-4, ID: cell_name
		23 text Content:
		24 container contentDiv
			306 text entry area (settable) ID: content_text, Value: <p>
Text for Fourth Cell.
</p>
			82 button Switch to Editor View
			83 text ** HTML View should only be used by users who are familiar with HTML
		84 text Image:
		85 container
			86 container
				87 text Select or type...
				88 combo box (collapsed, settable) ID: image, Secondary Actions: Expand
		89 pop up button (collapsed, settable) Value: Image, ID: image_type, Secondary Actions: Expand
			90 menu
				91 Select an option
				93 Image Section
				94 Image Group
				95 Video
				96 Upload
		97 text Link (URL):
		98 text field (settable) link
		99 text Column Order:
		100 stepper (settable, integer) Value: 4, ID: cell_order
		101 text Margin Top:
		102 pop up button (collapsed, settable) Value: Select an option, ID: marginTop, Secondary Actions: Expand
			103 menu
				105 None
				106 Margin Top - #1
				107 Margin Top - #2
				108 Margin Top - #3
				109 Margin Top - #4
				110 Margin Top - #5
		111 text Margin Left:
		112 pop up button (collapsed, settable) Value: Select an option, ID: marginLeft, Secondary Actions: Expand
			113 menu
				115 None
				116 Margin Left - #1
				117 Margin Left - #2
				118 Margin Left - #3
				119 Margin Left - #4
				120 Margin Left - #5
		121 text Margin Bottom:
		122 pop up button (collapsed, settable) Value: Select an option, ID: marginBottom, Secondary Actions: Expand
			123 menu
				125 None
				126 Margin Bottom - #1
				127 Margin Bottom - #2
				128 Margin Bottom - #3
				129 Margin Bottom - #4
				130 Margin Bottom - #5
		131 text Margin Right:
		132 pop up button (collapsed, settable) Value: Select an option, ID: marginRight, Secondary Actions: Expand
			133 menu
				135 None
				136 Margin Right - #1
				137 Margin Right - #2
				138 Margin Right - #3
				139 Margin Right - #4
				140 Margin Right - #5
		141 text Background Color:
		142 pop up button (collapsed, settable) Value: Select an option, ID: backgroundColor, Secondary Actions: Expand
			143 menu
				148 Red
				149 Green
				150 Blue
				151 Gray
				152 Yellow
				153 Cyan
				154 Magenta
				155 Lime
				156 Silver
				157 Maroon
				158 Olive
				159 Green
				160 Purple
				161 Teal
				162 Navy
				163 Orange
				164 Gainsboro
				165 Light Gray
				166 Dark Gray
				167 Dim Gray
				168 Slate Gray
				169 Light Slate Gray
				170 Dark Slate Gray
				171 White Smoke
				172 Light Coral
				173 Indian Red
				174 Crimson
				175 Fire Brick
				176 Dark Red
				177 Pink
				178 Light Pink
				179 Hot Pink
				180 Deep Pink
				181 Medium Violet Red
				182 Pale Violet Red
				183 Coral
				184 Tomato
				185 Orange Red
				186 Dark Orange
				187 Orange
				188 Moccasin
				189 Peach Puff
				190 Papaya Whip
				191 Saddle Brown
				192 Sienna
				193 Chocolate
				194 Peru
				195 Tan
				196 Burly Wood
				197 Wheat
				198 Gold
				199 Yellow
				200 Light Yellow
				201 Lemon Chiffon
				202 Khaki
				203 Pale Golden Rod
				204 Dark Khaki
				205 Lawn Green
				206 Chartreuse
				207 Green Yellow
				208 Lime Green
				209 Pale Green
				210 Light Green
				211 Medium Spring Green
				212 Spring Green
				213 Forest Green
				214 Sea Green
				215 Medium Sea Green
				216 Dark Sea Green
				217 Olive Drab
				218 Dark Olive Green
				219 Dark Green
				220 Light Cyan
				221 Pale Turquoise
				222 Aquamarine
				223 Medium Aquamarine
				224 Turquoise
				225 Medium Turquoise
				226 Dark Turquoise
				227 Light Sea Green
				228 Cadet Blue
				229 Dark Cyan
				230 Light Blue
				231 Powder Blue
				232 Sky Blue
				233 Light Sky Blue
				234 Deep Sky Blue
				235 Dodger Blue
				236 Cornflower Blue
				237 Royal Blue
				238 Medium Blue
				239 Dark Blue
				240 Midnight Blue
				241 Lavender
				242 Thistle
				243 Plum
				244 Violet
				245 Orchid
				246 Medium Orchid
				247 Dark Orchid
				248 Dark Violet
				249 Blue Violet
				250 Medium Purple
				251 Slate Blue
				252 Medium Slate Blue
				253 Dark Slate Blue
				254 Snow
				255 Honey Dew
				256 Mint Cream
				257 Azure
				258 Alice Blue
				259 Ghost White
				260 Floral White
				261 Old Lace
				262 Ivory
				263 Seashell
				264 Beige
				265 Linen
				266 Antique White
				267 Dark Slate Gray
				268 Dim Gray
				269 Slate Gray
		270 button Switch to Formatting Mode **
		271 text ** Formatting mode should only be used by users who are familiar with CSS
		272 text * - Required Fields
		273 text Text for Fourth Cell.
		274 button Save Column
		275 button Cancel
	276 container
```

### 32-cells-formatting

Interaction: Switch Cell Edit to Formatting Mode

Route: `http://localhost:3000/admin/cells/188/edit`

[Screenshot](screenshots/32-cells-formatting.jpg)

```text
	15 container
		16 text Content Type:
		17 container
			18 container
				19 text test-section
				20 combo box (collapsed, settable) ID: section_name, Secondary Actions: Expand
		21 text Column Name*:
		22 text field (settable) Value: test-section-4, ID: cell_name
		23 text Content:
		24 container contentDiv
			306 text entry area (settable) ID: content_text, Value: <p>
Text for Fourth Cell.
</p>
			82 button Switch to Editor View
			83 text ** HTML View should only be used by users who are familiar with HTML
		84 text Image:
		85 container
			86 container
				87 text Select or type...
				88 combo box (collapsed, settable) ID: image, Secondary Actions: Expand
		89 pop up button (collapsed, settable) Value: Image, ID: image_type, Secondary Actions: Expand
			90 menu
				91 Select an option
				93 Image Section
				94 Image Group
				95 Video
				96 Upload
		97 text Link (URL):
		98 text field (settable) link
		99 text Column Order:
		100 stepper (settable, integer) Value: 4, ID: cell_order
		307 heading Current, Value: 3
			308 text Current
		309 text {
  "classes": "m-3"
} classes
		310 text field (settable) Value: m-3, ID: classes
		311 button Delete
		312 heading Add New Entry, Value: 3
			313 text Add New Entry
		314 pop up button (collapsed, settable) Value: Select an option, ID: formattingField, Secondary Actions: Expand
			315 menu
				317 Select an option to add
				318 Container Classes
				319 Styles
				320 Image Caption
				321 Image Caption Position
				322 Caption Classes
				323 Caption Classes
				324 Expanding Rows
				325 Expanding Cells
				326 Slide Show Images
				327 Slide Show Type (Prompt)
		270 button Switch to Normal Mode
		271 text ** Formatting mode should only be used by users who are familiar with CSS
		272 text * - Required Fields
		273 text Text for Fourth Cell.
		274 button Save Column
		275 button Cancel
	276 container
```

### 33-site-setups-view

Interaction: Click Site Setups; click first row View

Route: `http://localhost:3000/admin/site_setups/1`

[Screenshot](screenshots/33-site-setups-view.jpg)

```text
	15 text Configuration Name
	16 text default
	17 text Site Owner
	18 text Paul Carrick
	19 text Site Name
	20 text Paul Carrick
	21 text Default Site information
	22 text Yes
	23 text Site Domain
	24 text paul-carrick.com
	25 text Site Host
	26 text paul-carrick.com
	27 text Site URL
	28 text https://paul-carrick.com
	29 text Guest User Name
	30 text Guest User
	31 text Email Server (SMTP host)
	32 text email-smtp.us-west-2.amazonaws.com
	33 text Email Server Port
	34 text 465
	35 text Eail Server User Name
	36 text AKIA4T4OCMYU4RARO7O5
	37 text Email Server Authentication
	38 text login
	39 text Email Server Default Domain
	40 text paul-carrick.com
	41 text Contact "Email From:"
	42 text paul@paul-carrick.com
	43 text Contact Email To
	44 text paul@paul-carrick.com
	45 text Contact Email Subject
	46 text Contact request from Paul-Carrick.com.
	47 text Header Background Color
	48 text #0d6efd
	49 text Header Text Color
	50 text white
	51 text Footer Background Color
	52 text #0d6efd
	53 text Footer Text Color
	54 text white
	55 text Container Background Color
	56 text white
	57 text Container Text Color
	58 text black
	59 text Page Background Image
	60 text none
	61 text Facebook URL
	62 text https://www.facebook.com/paul.j.carrick
	63 text Twitter URL
	64 text https://x.com/PaulJCarrick
	65 text Instagram URL
	66 text https://www.instagram.com/pauljcarrick/
	67 text LinkedIn URL
	68 text https://www.linkedin.com/in/pauljcarrick/
	69 text GitHub URL
	70 text https://github.com/PaulCarrick
	71 text Copyright
	72 text Copyright © 2024 Paul Carrick all rights reserved
	73 container
```

### 34-users-view

Interaction: Click Users; click first row View

Route: `http://localhost:3000/admin/users/2`

[Screenshot](screenshots/34-users-view.jpg)

```text
	15 text Email:
	16 text guest@paul-carrick.com
	17 text Name:
	18 text Guest User
	19 text Admin:
	20 text No
	21 text Super:
	22 text No
	23 text Roles:
	24 text Approved:
	25 text No
	26 container
```

### 35-menu-items-view

Interaction: Click Menu Items; click first row View

Route: `http://localhost:3000/admin/menu_items/24`

[Screenshot](screenshots/35-menu-items-view.jpg)

```text
	15 text Menu Type:
	16 text Main
	17 text Label:
	18 text Admin Dashboard
	19 text Icon:
	20 image Icon
	21 text /images/gear.svg
	22 text Options:
	23 text image-file
	24 text Link:
	25 text /admin
	26 text Access:
	27 text Menu Order:
	28 text 6
	29 text Parent:
	30 container
```

### 36-footer-items-view

Interaction: Click Footer Items; click first row View

Route: `http://localhost:3000/admin/footer_items/15`

[Screenshot](screenshots/36-footer-items-view.jpg)

```text
	15 text Label:
	16 text Admin Dashboard
	17 image Icon
	18 text /images/gear.svg
	19 text Options:
	20 text Link:
	21 text /admin
	22 text Access:
	23 text Footer Order:
	24 text 16
	25 text Parent:
	26 text 12
	27 container
```

### 37-pages-view

Interaction: Click Pages; click first row View

Route: `http://localhost:3000/admin/pages/1`

[Screenshot](screenshots/37-pages-view.jpg)

```text
	15 container bio
		16 link Description: Edit Column, Value: localhost:3000/admin/cells/63/edit
		17 link Description: Delete Column, Value: localhost:3000/admin/cells/63
		18 container contents
			19 text Paul was born at Queen of Angels Hospital in Los Angeles, CA, and spent his early years in Panorama City in the San Fernando Valley. At 8, his family moved to Newhall, CA (now Santa Clarita), where he lived until his 30s before heading up to Washington state.
			20 text Paul became a Christian at 14 after reading The Late Great Planet Earth, and he got involved with several churches, including Agape, a "Jesus People" church. With a couple of friends, he formed a small vocal group, performing at various churches. When he turned 18, he went on to attend Biola College.
			21 text He met his wife, Virginia, when he was 16. They didn’t fall in love right away but quickly became best friends, staying close for seven years before getting married. Paul loves music, and he and Virginia even played in a band together called Born Again, with him on guitar and vocals and Virginia singing. Virginia’s daughter, Joy, was nine months old when they got married, and Paul loved being a dad. They sang to each other at their wedding, and not long after, they moved to Washington. A year later, they welcomed their son, Jonathan.
			22 text Jonathan had a challenging start in life—he was diagnosed with a heart defect (aortic stenosis) at just over a month old, requiring open-heart surgery. Over the years, he’s been through two heart surgeries, including a valve replacement and pacemaker implant at 14. Despite a few close calls, Jon’s resilience shines through. In 1998, the family moved to Orcas Island, which has been home ever since.
			23 text Paul’s daughter, Joy, now has three children: Brandon, Kevin, and Jessica. They all live together on Orcas Island, making it a true extended family home.
			24 container
				25 text Originally planning to study psychology, Paul switched to computer science after his parents gifted him a computer. After graduating, he launched a career as a software engineer, working for various companies. A highlight was joining 
				26 link Description: Amazon.com, Value: localhost:3000/employment?section_name=amazon
				27 text  in its early startup days, where he played a key role in developing their shipping software, boosting performance by 85%.
			28 text Today, Paul, Virginia, Joy, Jon, and Brandon, Kevin, and Jessica are happily settled on Orcas Island, enjoying life together as one big family.
	29 container
```

### 38-sections-view

Interaction: Click Sections; click first row View

Route: `http://localhost:3000/admin/sections/152`

[Screenshot](screenshots/38-sections-view.jpg)

```text
	15 text Content Type:
	16 text bio
	17 text Section Name:
	18 text legacy-test-1790710784
	19 text Section Order:
	20 text 999
	21 text Image:
	22 text Link:
	23 text Formatting:
	24 text {}
	25 text Description:
	26 link Description: Edit Section, Value: localhost:3000/admin/sections/152/edit
	27 link Description: Back to Sections, Value: localhost:3000/admin/sections
	28 container
```

### 39-cells-view

Interaction: Click Cells; click first row View

Route: `http://localhost:3000/admin/cells/188`

[Screenshot](screenshots/39-cells-view.jpg)

```text
	15 container
		16 link Description: Edit Column, Value: localhost:3000/admin/cells/188/edit
		17 link Description: Delete Column, Value: localhost:3000/admin/cells/188
		18 text Text for Fourth Cell.
	19 text Section Name:
	20 text test-section
	21 text Cell Name:
	22 text test-section-4
	23 text Cell Type:
	24 text text
	25 text Cell Order:
	26 text 4
	27 text Description:
	28 text Text for Fourth Cell.
	29 text Image:
	30 text Link:
	31 text Formatting:
	32 container
		33 text {
		34 text     "classes": "m-3"
		35 text }
	36 text Width:
	37 text 25%
	38 text Content:
	39 text Text for Fourth Cell.
	40 link Description: Edit Cell, Value: localhost:3000/admin/cells/188/edit
	41 link Description: Back to Cells, Value: localhost:3000/admin/cells
	42 container
```

### 40-image-files-view

Interaction: Click Image Files; click first row View

Route: `http://localhost:3000/admin/image_files/185`

[Screenshot](screenshots/40-image-files-view.jpg)

```text
	15 link localhost:3000/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsiZGF0YSI6MTk5LCJwdXIiOiJibG9iX2lkIn19--2eb8fb9e885671280f06ed7acd485b8c0c17efb9/nava-logo.jpg
	16 text Name:
	17 text nava-logo
	18 text caption:
	19 text Description:
	20 text MIME Type:
	21 text image/png
	22 text Group:
	23 text Slide Order:
	24 container
```

### 41-blogs-view

Interaction: Click Blogs; click first row View

Route: `http://localhost:3000/admin/blog_posts/4`

[Screenshot](screenshots/41-blogs-view.jpg)

```text
	15 heading Blog, Value: 1
		16 text Blog
	17 heading Switching to Quill., Value: 2
		18 text Switching to Quill.
	19 text 2025-01-07 22:53:38 UTC - Paul Carrick
	20 text I really like Quill. It's an excellent HTML Editor for React. I've replaced Trix with it.
	21 container
```

### 42-blogs-html

Interaction: New Blog: switch to HTML View

Route: `http://localhost:3000/admin/blog_posts/new`

[Screenshot](screenshots/42-blogs-html.jpg)

```text
	15 container
		16 heading New Blog Post, Value: 1
			17 text New Blog Post
		18 text Author*
		19 text field (settable) Author*, Value: Paul Carrick, ID: blog_post_author
		20 text Title*
		21 text field (settable) Title*, ID: blog_post_title
		22 text Visibility
		23 pop up button (collapsed, settable) Visibility, Value: Public, ID: blog_post_visibility, Secondary Actions: Expand
			24 menu
				26 Private
		27 text Blog Type
		28 pop up button (collapsed, settable) Blog Type, Value: Personal, ID: blog_post_blog_type, Secondary Actions: Expand
			29 menu
				31 Professional
		32 text Post*
		33 container blog-post-content
			34 container
				35 button (collapsed) Sans Serif, Secondary Actions: Expand
					36 text Sans Serif
					37 image
			38 container
				39 button (collapsed) Normal, Secondary Actions: Expand
					40 text Normal
					41 image
			42 container
				43 button
					44 image
				45 button
					46 image
				47 button
					48 image
				49 button
					50 image
			51 container
				52 button (collapsed) Secondary Actions: Expand
					53 image
				54 button (collapsed) Secondary Actions: Expand
					55 image
			56 container
				57 button
					58 image
				59 button
					60 image
			61 container
				62 button (collapsed) Normal, Secondary Actions: Expand
					63 text Normal
					64 image
			65 container
				66 button
					67 image
				68 button
					69 image
			70 container
				71 button (collapsed) Secondary Actions: Expand
					72 image
			73 container
				74 button
					75 image
				76 button
					77 image
				78 button
					79 image
				80 button
					81 image
			82 container
				83 button
					84 image
			85 container
				86 button <div>
			87 container
				88 container 

					124 text Enter the content for the post...
		90 button Switch to HTML View **
		91 text ** HTML View should only be used by users who are familiar with HTML * - Required Fields
		92 button Save Blog Post
		93 link Description: Cancel, Value: localhost:3000/admin/blog_posts
	94 container
```

### 43-blogs-sort

Interaction: Click Title sort arrow; observe ascending sort route

Route: `http://localhost:3000/admin/blog_posts?direction=asc&sort=title`

[Screenshot](screenshots/43-blogs-sort.jpg)

```text
	15 link Description: Author ↓↑, Value: localhost:3000/admin/blog_posts?direction=asc&sort=author
	16 link Description: Title ↓, Value: localhost:3000/admin/blog_posts?direction=desc&sort=title
	17 link Description: Posted ↓↑, Value: localhost:3000/admin/blog_posts?direction=asc&sort=posted
	18 text Contents
	19 link Description: Clear Sort, Value: localhost:3000/admin/blog_posts?direction=asc&sort=title#
	20 container
		21 text Paul Carrick Adding Search 2024-11-25 08:10:56 UTC I'm adding search capability to my website via Ransack.
		22 container
			23 link Description: View, Value: localhost:3000/admin/blog_posts/2
			24 link Description: Edit, Value: localhost:3000/admin/blog_posts/2/edit
			25 link Description: Delete, Value: localhost:3000/admin/blog_posts/2/delete
		26 text Paul Carrick Paul's First Entry 2024-11-21 09:38:59 UTC This is my first 
		27 text post. I've been developing this website and the blog functionality is now ready. If you are seeing this post it's working.
		28 container
			29 link Description: View, Value: localhost:3000/admin/blog_posts/1
			30 link Description: Edit, Value: localhost:3000/admin/blog_posts/1/edit
			31 link Description: Delete, Value: localhost:3000/admin/blog_posts/1/delete
		32 text Paul Carrick Switching to Quill. 2025-01-07 22:53:38 UTC I really like Quill. It's an excellent HTML Editor for React. I've replaced Trix with it.
		33 container
			34 link Description: View, Value: localhost:3000/admin/blog_posts/4
			35 link Description: Edit, Value: localhost:3000/admin/blog_posts/4/edit
			36 link Description: Delete, Value: localhost:3000/admin/blog_posts/4/delete
	37 link Description: New Blog, Value: localhost:3000/admin/blog_posts/new
	38 container Pagination
		39 content list
			40 text Page 1 of 1
			41 link Description: First, Value: localhost:3000/admin/blog_posts?direction=asc&page=1&sort=title
			42 link Description: Previous, Value: localhost:3000/admin/blog_posts?direction=asc&sort=title
			43 link Description: Next, Value: localhost:3000/admin/blog_posts?direction=asc&sort=title
			44 link Description: Last, Value: localhost:3000/admin/blog_posts?direction=asc&page=1&sort=title
	45 container blog_post_search
		46 text Author
		47 search text field (settable) Author, ID: q_author_cont
		48 text Title
		49 search text field (settable) Title, ID: q_title_cont
		50 text Posted
		51 text field (settable) Description: Please enter the date in the format YYYY-DD-MM., ID: q_posted_date_eq
		52 text Contents
		53 search text field (settable) Contents, ID: q_content_cont
		54 container
			55 button Search Blogs
			56 link Description: Clear Search, Value: localhost:3000/admin/blog_posts?clear_search=true
	57 container
```

### 44-blogs-search

Interaction: Submit empty read-only blog search

Route: `http://localhost:3000/admin/blog_posts?q%5Bauthor_cont%5D=&q%5Btitle_cont%5D=&q%5Bposted_date_eq%5D=&q%5Bcontent_cont%5D=&commit=Search+Blogs`

[Screenshot](screenshots/44-blogs-search.jpg)

```text
	15 link Description: Author ↓↑, Value: localhost:3000/admin/blog_posts?direction=asc&sort=author
	16 link Description: Title ↓↑, Value: localhost:3000/admin/blog_posts?direction=asc&sort=title
	17 link Description: Posted ↓↑, Value: localhost:3000/admin/blog_posts?direction=asc&sort=posted
	18 text Contents
	19 link Description: Clear Sort, Value: localhost:3000/admin/blog_posts?q%5Bauthor_cont%5D=&q%5Btitle_cont%5D=&q%5Bposted_date_eq%5D=&q%5Bcontent_cont%5D=&commit=Search+Blogs#
	20 container
		21 text Paul Carrick Adding Search 2024-11-25 08:10:56 UTC I'm adding search capability to my website via Ransack.
		22 container
			23 link Description: View, Value: localhost:3000/admin/blog_posts/2
			24 link Description: Edit, Value: localhost:3000/admin/blog_posts/2/edit
			25 link Description: Delete, Value: localhost:3000/admin/blog_posts/2/delete
		26 text Paul Carrick Paul's First Entry 2024-11-21 09:38:59 UTC This is my first 
		27 text post. I've been developing this website and the blog functionality is now ready. If you are seeing this post it's working.
		28 container
			29 link Description: View, Value: localhost:3000/admin/blog_posts/1
			30 link Description: Edit, Value: localhost:3000/admin/blog_posts/1/edit
			31 link Description: Delete, Value: localhost:3000/admin/blog_posts/1/delete
		32 text Paul Carrick Switching to Quill. 2025-01-07 22:53:38 UTC I really like Quill. It's an excellent HTML Editor for React. I've replaced Trix with it.
		33 container
			34 link Description: View, Value: localhost:3000/admin/blog_posts/4
			35 link Description: Edit, Value: localhost:3000/admin/blog_posts/4/edit
			36 link Description: Delete, Value: localhost:3000/admin/blog_posts/4/delete
	37 link Description: New Blog, Value: localhost:3000/admin/blog_posts/new
	38 container Pagination
		39 content list
			40 text Page 1 of 1
			41 link Description: First, Value: localhost:3000/admin/blog_posts?commit=Search+Blogs&page=1&q%5Bauthor_cont%5D=&q%5Bcontent_cont%5D=&q%5Bposted_date_eq%5D=&q%5Btitle_cont%5D=
			42 link Description: Previous, Value: localhost:3000/admin/blog_posts?commit=Search+Blogs&q%5Bauthor_cont%5D=&q%5Bcontent_cont%5D=&q%5Bposted_date_eq%5D=&q%5Btitle_cont%5D=
			43 link Description: Next, Value: localhost:3000/admin/blog_posts?commit=Search+Blogs&q%5Bauthor_cont%5D=&q%5Bcontent_cont%5D=&q%5Bposted_date_eq%5D=&q%5Btitle_cont%5D=
			44 link Description: Last, Value: localhost:3000/admin/blog_posts?commit=Search+Blogs&page=1&q%5Bauthor_cont%5D=&q%5Bcontent_cont%5D=&q%5Bposted_date_eq%5D=&q%5Btitle_cont%5D=
	45 container blog_post_search
		46 text Author
		47 search text field (settable) Author, ID: q_author_cont
		48 text Title
		49 search text field (settable) Title, ID: q_title_cont
		50 text Posted
		51 text field (settable) Description: Please enter the date in the format YYYY-DD-MM., ID: q_posted_date_eq
		52 text Contents
		53 search text field (settable) Contents, ID: q_content_cont
		54 container
			55 button Search Blogs
			56 link Description: Clear Search, Value: localhost:3000/admin/blog_posts?clear_search=true
	57 container
```

### 45-sections-next

Interaction: Click Sections Next pagination

Route: `http://localhost:3000/admin/sections?page=2`

[Screenshot](screenshots/45-sections-next.jpg)

```text
	15 heading Section, Value: 2
		16 text Section
	17 container
		18 link Description: Clear Sort, Value: localhost:3000/admin/sections?clear_sort=true
		19 link Description: View, Value: localhost:3000/admin/sections/151
		20 link Description: Edit, Value: localhost:3000/admin/sections/151/edit
		21 link Description: Delete, Value: localhost:3000/admin/sections/151/delete
	22 container Pagination
		23 content list
			24 link Description: First, Value: localhost:3000/admin/sections?page=1
			25 link Description: Previous, Value: localhost:3000/admin/sections?page=1
			26 link Description: Next, Value: localhost:3000/admin/sections?page=3
			27 link Description: Last, Value: localhost:3000/admin/sections?page=65
	28 link Description: Type ↓↑, Value: localhost:3000/admin/sections?direction=asc&sort=content_type
	29 link Description: Name ↓↑, Value: localhost:3000/admin/sections?direction=asc&sort=section_name
	30 link Description: Order: ↓↑, Value: localhost:3000/admin/sections?direction=asc&sort=section_order
	31 link Description: Image: ↓↑, Value: localhost:3000/admin/sections?direction=asc&sort=image
	32 link Description: URL: ↓↑, Value: localhost:3000/admin/sections?direction=asc&sort=link
	33 text bio
	34 text legacy-test-1790710415
	35 text 999
	36 container Pagination
		37 content list
			38 text Page 2 of 65
			39 link Description: First, Value: localhost:3000/admin/sections?page=1
			40 link Description: Previous, Value: localhost:3000/admin/sections?page=1
			41 link Description: Next, Value: localhost:3000/admin/sections?page=3
			42 link Description: Last, Value: localhost:3000/admin/sections?page=65
	43 container sections_search_form
		44 text Content Type
		45 search text field (settable) Content Type, ID: q_content_type_cont
		46 text Section Name
		47 search text field (settable) Section Name, ID: q_section_name_cont
		48 text Image
		49 search text field (settable) Image, ID: q_image_cont
		50 text URL
		51 search text field (settable) URL, ID: q_link_cont
		52 text Description
		53 search text field (settable) Description, ID: q_description_cont
		54 container
			55 button Search Sections
			56 link Description: Clear Search, Value: localhost:3000/admin/sections?clear_search=true
	57 container
```

### 46-sections-second-edit

Interaction: Sections page 2: click Edit to inspect another Section variant

Route: `http://localhost:3000/admin/sections/151/edit`

[Screenshot](screenshots/46-sections-second-edit.jpg)

```text
	15 container GenerateCells
		16 text Templates:
		17 pop up button (collapsed, settable) Value: Select an option, ID: cellTemplates, Secondary Actions: Expand
			18 menu
				20 Text Only
				21 Image Only
				22 Dual Column - Text Left
				23 Dual Column - Text Right
				24 Three Column
				25 Four Column
				26 Five Column
		27 button Generate Columns
	28 container
```


## Add Section verification after fix

Rerun after controller correction: Add Section redirects successfully to the new Section editor. It renders Templates and Generate Columns, with no Cancel control. No columns were generated. Temporary section 154 was removed via the application cancellation route, returning to Page Edit.

![Fixed Add Section screen](screenshots/47-page-add-section-fixed.jpg)
