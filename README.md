# Jump Start Server

Jump Start Server is an open source, self-hosted website builder. Create pages, manage navigation, and publish blog posts from a browser without writing code. Search and contact forms are built in, and you choose where to host your site.

[See a live example](https://paul-carrick.com) · [Follow the quickstart](docs/new-site-tutorial.md) · [View releases](https://github.com/PaulCarrick/jump-start-website/releases)

## What you can build

Use Jump Start Server to create a personal website, portfolio, blog, or small organization site. Once the server is running, you can manage your site from the admin interface.

- Create and edit pages with text and images.
- Configure navigation in the header and footer.
- Write and publish blog posts.
- Let visitors search your site and contact you through a built-in form.

## Why use Jump Start Server?

### 🚀 Free and open source

Use, inspect, and modify the software under the Apache License 2.0. The software is free. Hosting and domain registration costs depend on what you choose.

### 🏗️ Control your site’s layout

Arrange page content and configure your header and footer navigation from the admin interface. You can update the site as your content changes.

### 🔓 Choose where you host

Run Jump Start Server on infrastructure you control. If you switch hosting providers, you can migrate the application, database, and uploaded files to your new host.

### 💰 Start with affordable hosting

You can run a personal site on a small cloud server. The live example runs on Amazon Lightsail and uses Let’s Encrypt for HTTPS.

## Get started

Follow the [new site tutorial](docs/new-site-tutorial.md) to run Jump Start Server with Docker. Once it’s running, open the admin interface, create your first page, and add it to your site navigation.

See [GitHub Releases](https://github.com/PaulCarrick/jump-start-website/releases) for versioned downloads and release notes. For additional setup options, see the [installation guide](INSTALLATION.md).

## Live example

[Paul Carrick’s personal website](https://paul-carrick.com) runs on Jump Start Server. Browse it to see how pages, navigation, and blog posts work together on a published site.

## For developers

Jump Start Server uses Ruby on Rails and PostgreSQL, with JavaScript and TypeScript in the frontend. Docker configurations are included for the application and database.

- [`app/`](app/) contains the application code.
- [`spec/`](spec/) contains the RSpec test suite.
- [`docs/`](docs/) contains tutorials and project documentation.

## Help and contributions

If you find a bug or have a feature idea, [open a GitHub issue](https://github.com/PaulCarrick/jump-start-website/issues). For a bug report, include the version you’re running, how you installed it, and the steps to reproduce the problem.

Pull requests are welcome. For a larger change, start with an issue so we can discuss the approach.

## License

Jump Start Server is available under the [Apache License 2.0](LICENSE).
