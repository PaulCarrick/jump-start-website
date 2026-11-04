# Build your first Jumpstart website

This walkthrough takes you from a new installation to a home page and an About page with text and images. Choose one installation path, then follow the shared editing steps. If Jumpstart is already running, start at **Edit your Site Setup** below. Use Help for the full reference; this tutorial sits immediately below Help in the admin sidebar.

## Choose your installation

Use the native path when you want Rails and PostgreSQL installed on your computer or server. Use containers when you want Docker to run those dependencies for you. Start with a new installation, not an existing production database. The quick-start Compose setup is separate from the legacy production deployment scripts.

## Path A: native installation from the repository

1. Install Git, PostgreSQL 15 or newer, the Ruby version in `.ruby-version` (currently 4.0.7), and Node.js 22.12 or newer. You also need the development libraries for PostgreSQL, YAML, and libvips, and a compiler for native gems. Start PostgreSQL. Operating-system package names differ; the repository's installation scripts provide a Debian-oriented assisted installation if you prefer that route.
2. Download the source and enter its directory:

```
git clone https://github.com/PaulCarrick/jump-start-website.git
cd jump-start-website
```

3. Install the dependencies:

```
gem install bundler -v 4.0.20
bundle install
npm ci
```

4. Create a PostgreSQL login for this local installation. Run the following as a PostgreSQL administrator, then enter a new password when prompted:

```
createuser --pwprompt --createdb jump_start
```

The role must be permitted to load the schema and its extensions. If schema loading reports an extension permission error, ask the database administrator to grant the required permission or install the extension; do not ignore the error.

5. Copy `example.env` to `.env`. Keep that file private. Set DB_HOST to `localhost`, DB_PORT to `5432`, DB_USERNAME to `jump_start`, DB_DATABASE to `jump_start`, and DB_PASSWORD to the password you just chose. Set RAILS_ENV to `development`, SERVER_HOST to `localhost`, SERVER_PORT and INTERNAL_PORT to `3000`, SERVER_MODE to `http`, and SSL_MODE to `false`. Leave DOCKERIZED unset. Set USER_PASSWORD to a strong, unique initial account password. Values containing spaces must be quoted because the next step loads this file in your shell.
6. Load your settings and prepare the database. The preparation flag lets models load before their tables exist; it applies only to this command:

```
set -a
. ./.env
set +a
ASSETS_PRECOMPILE=1 bundle exec rails db:prepare
bundle exec rails db:seed
npm run build
npm run build:css
bundle exec puma -C /dev/null -b tcp://127.0.0.1:3000
```

7. Open `http://localhost:3000`. Sign in with `jump_start@example.com` and the USER_PASSWORD you supplied. The native seeds also create `guest@example.com` with that password; review both accounts in Users and change their credentials before public use. Keep the terminal open while working; Ctrl+C stops the local server.

This is a local development installation. Public native hosting additionally needs production settings, persistent process management, backups, and HTTPS; do not expose the development server as your public site.

## Path B: two-container installation

1. Install and start Docker with Docker Compose. Install Git and Python 3 for the setup command.
2. Download the repository:

```
git clone https://github.com/PaulCarrick/jump-start-website.git
cd jump-start-website
```

3. Generate private settings, then build and start the two containers:

```
bin/docker-setup
docker compose up -d --build
docker compose ps
```

The setup command creates `.env` without replacing an existing file. If it already exists, inspect it rather than deleting it: it may belong to another installation. Rails prepares the databases and creates the starter site and one administrator automatically. PostgreSQL and uploads use persistent Docker volumes.

4. Wait until both services are healthy. On the first run, downloads and database preparation can take several minutes. Use `docker compose logs rails` if Rails does not become healthy.
5. Open `http://localhost:3000`. Read ADMIN_EMAIL and ADMIN_PASSWORD in your local `.env`, and use them to sign in. Do not share the file or commit it to Git.
6. To stop the installation, run `docker compose down`. To resume, run `docker compose up -d`. Do not add `-v` to the stop command: that deletes the database and uploads.

For a release with published images, obtain the release's Compose file and setup script, generate `.env`, and set JUMPSTART_RAILS_IMAGE and JUMPSTART_DATABASE_IMAGE to the supplied versioned image names. Then run `docker compose pull` followed by `docker compose up -d --no-build`. Use the exact image names provided by the release; older Docker Hub images are not interchangeable with this quick-start setup.

## Edit your Site Setup

We will build a small example called **Willow Studio**. Substitute your own name, wording, and photographs.

1. Sign in and open the admin area. Choose **Site Setups** in the sidebar.
2. Edit the existing default setup. For your first website, use this starter setup rather than creating a second site database.
3. Set Site Name to **Willow Studio**. Review Configuration Name, owner name, copyright, colors, and the header/footer settings. Keep the existing database value: changing that field does not rename the running database.
4. Keep Site URL at `http://localhost:3000` while following the tutorial locally. Keep the domain/host consistent with that address. Changing the URL to a public domain before it resolves to this server can prevent the local address from matching the site.
5. Review the email and CAPTCHA settings. Leave optional integrations disabled until you have their actual credentials and have tested them.
6. Save the Site Setup. Saving creates a draft; review it under **Deploy Changes** and deploy it when ready. Confirm the website still opens and displays the new site name.

If you intend to add another independently routed website to an existing installation, use **New Site Setup** instead, give it a unique database name and URL, and follow the separate site-database provisioning procedure. That is different from adding pages to this first website.

## Edit the home page

1. Open **Pages**. Locate the starter home page and choose **Edit**. Keep its existing Page Name and Section Group so the home route continues to find its content.
2. Change its title to **Welcome to Willow Studio**.
3. Review the existing sections. Edit the welcome section, or choose **Add Section** to add one. Choose a **Text Only** template for the introduction.
4. Give the section a descriptive name, such as **Home introduction**, and enable it. Set its order so it appears before later sections.
5. Open **Edit Column** on the text column. Enter: “Welcome to Willow Studio. We create thoughtful spaces for everyday living.” Use the rich-text toolbar for headings, paragraphs, and emphasis; you do not need to write HTML.
6. Choose **Save Column**, then save the section. If you opened editors inside another editor, save each parent after returning to it. Finally save the page.
7. Review the page preview. Changes remain drafts until deployed; the public site can still show the previous version.

## Add your first image

1. Open **Image Files**, then **New Image**. Alternatively, use **New Image** beside an image selector while editing a column.
2. Enter a useful unique name, such as `willow-studio-welcome`. Choose a JPEG or PNG photograph and check its MIME type. Add a caption and description where appropriate. Use a reasonably sized web image rather than an unnecessarily large original.
3. Choose **Save Image**. If you used the dialog, return to the image selector and select the new image. Uploading saves the file separately; cancelling a page draft does not undo an upload.
4. Return to the home page. Add a section using an image/text template, or edit an existing image column.
5. Select the uploaded image and enter accompanying text such as “Explore our recent projects.” Check the column widths and image fit in the preview.
6. Save the column, section, and page as applicable. Review **Deploy Changes**, deploy the intended records, and open the home page to check the result.

## Create an About page with text and images

1. Open **Pages**, then **New page**.
2. Enter Page Title **About Willow Studio**, a unique Page Name such as `about`, and a unique Section Group such as `about-willow`. Set Page Access for public viewing and ensure the content is enabled.
3. Once the required fields are filled, choose **New Section**, or save the page and use **Add Section**.
4. Choose a text/image template. Name the section **Our story**, enable it, and set its order.
5. Edit the text column. Add a heading and two short paragraphs explaining who you are, what you offer, and whom you help. Save the column.
6. Edit the image column. Select an existing image or use **New Image** to upload another. Save the column and section, then save the page.
7. Add another Text Only section called **What we do** if you want more content. Use a list for your services. Save all open editors.

## Add the page to navigation

1. Use the page editor's menu placement controls if offered. Otherwise, open **Menu Items** and choose **New Menu Item**.
2. Choose Menu Type **Main**. Set the visible label to **About** and use the page selection control to link to your About page where available. For this example, the manual link is `/about`, based on the Page Name `about`; the display title is not its URL.
3. Set Enabled, choose the appropriate parent/group if needed, and set the order relative to the other navigation items. Save.
4. Open **Deploy Changes**. Review the Site Setup, page, sections, columns, and menu drafts you intend to publish. Deploy the selected changes and read any reported errors before proceeding.
5. Open the public website and click **About**. Check that it opens the intended page and that the text and images appear. Repeat these steps for Services, Projects, or another page.

## Review before sharing

1. Check Home and every new page both signed in and signed out. Confirm public pages do not require an administrator login.
2. Narrow the browser to a phone-sized width. Check text wrapping, image cropping, button alignment, and the navigation menu.
3. Test links and review spelling, captions, and image descriptions. Confirm the new page is reachable from navigation.
4. Confirm only intended drafts were deployed. Saving and deploying are separate steps; cancelling an editor does not undo an earlier save.
5. Back up the database, uploaded files, and private configuration before upgrading or moving the site.
6. For public hosting, configure your domain, HTTPS, and forwarding first, then update Site URL and related settings to the real address. The container quick start is local HTTP by default. Do not replace an existing production deployment with it without a migration plan.

## If something does not appear

- **A new page is missing:** check Enabled, access, its navigation link, and whether its drafts were deployed.
- **Text changes disappeared after closing an editor:** save the column, then its parent section/page where required.
- **An uploaded image is not shown:** select it in the column, save the content, and deploy the draft. Uploading alone does not place an image on a page.
- **The site stops matching the local address:** check Site URL and routing settings. Use the same address the setup is configured to serve.
- **Containers do not start:** run `docker compose ps` and `docker compose logs rails db`; keep the private configuration and volumes intact while investigating.
