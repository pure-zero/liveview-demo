# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

### Setup and Dependencies
- `mix setup` - Install dependencies, setup database, and build assets
- `mix deps.get` - Install/update Elixir dependencies only

### Running the Application
- `mix phx.server` - Start Phoenix server (visit localhost:4000)
- `iex -S mix phx.server` - Start server with interactive Elixir shell

### Database Operations
- `mix ecto.create` - Create database
- `mix ecto.migrate` - Run database migrations
- `mix ecto.reset` - Drop and recreate database with fresh data
- `mix ecto.setup` - Create database, run migrations, and seed data

### Asset Management
- `mix assets.setup` - Install Tailwind and esbuild if missing
- `mix assets.build` - Compile assets (Tailwind CSS + esbuild JS)
- `mix assets.deploy` - Build and minify assets for production

### Testing and Quality
- `mix test` - Run all tests (creates test DB automatically)
- `mix test test/path/to/specific_test.exs` - Run specific test file
- `mix test --only tag_name` - Run tests with specific tag
- `mix format` - Format Elixir code
- `mix precommit` - Run full quality checks (compile with warnings as errors, format, test)

## Architecture Overview

### Application Structure
This is a standard Phoenix 1.8 application with the following key components:

- **Application**: `Phxproj.Application` - OTP supervision tree including Repo, PubSub, Telemetry, and Endpoint
- **Web Layer**: `PhxprojWeb` - Contains controllers, views, LiveViews, and routing
- **Data Layer**: `Phxproj.Repo` - Ecto repository for PostgreSQL database operations
- **Configuration**: Environment-specific configs in `config/` directory

### Key Modules
- `PhxprojWeb.Router` - HTTP routing with `:browser` and `:api` pipelines
- `PhxprojWeb.Endpoint` - Phoenix endpoint with LiveView sockets and static file serving
- `PhxprojWeb.Telemetry` - Application metrics and monitoring

### Development Features
- **LiveReload**: Automatically reloads browser on file changes in development
- **LiveDashboard**: Available at `/dev/dashboard` in development for metrics and debugging
- **Swoosh Mailbox**: Available at `/dev/mailbox` for email preview in development

### Database Configuration
- **Development**: PostgreSQL with database `phxproj_dev` (username/password: postgres/postgres)
- **Test**: Uses Ecto.Adapters.SQL.Sandbox for test isolation
- **Migration**: Generates UTC datetime timestamps by default

### Asset Pipeline
- **Tailwind CSS**: Configured for styling with live reloading
- **esbuild**: JavaScript bundling with ES2022 target and source maps in development
- **Static Assets**: Served from `priv/static/` with gzip compression in production