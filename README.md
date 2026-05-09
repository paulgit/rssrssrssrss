# rssrssrss

A simple, stateless SPA that allows users to combine multiple RSS feeds into a single RSS feed URL.

## Features

- Combine any number of RSS feeds into a single feed
- Simple, intuitive interface
- No account required - just enter your feeds and get a URL
- Combined feeds are sorted by date (newest first)
- Original source information is preserved in the merged feed
- RSS feeds are compressed using LZ-string for better compression, and then [translated into a URI-friendly alphabet space](https://github.com/pieroxy/lz-string/blob/master/src/encodedURIComponent/compressToEncodedURIComponent.ts)

## Development

### Prerequisites

- Bun 1.0+
- Node.js 18+ (required by `./docker-build.sh`)

### Setup

```bash
# Clone the repository
git clone <repository-url>
cd rssrssrss

# Install dependencies
bun install

# Run the development server
bun dev
```

Open [http://localhost:3030](http://localhost:3030) with your browser to see the result.

### Available Scripts

```bash
bun dev      # Start development server
bun build    # Build for production
bun start    # Start production server
bun run lint # Run linter
bun run format # Format code with Biome
```

## Docker

The production image is built on [Google Distroless](https://github.com/GoogleContainerTools/distroless) (`gcr.io/distroless/nodejs24-debian13:nonroot`) for a minimal attack surface—no shell, package manager, npm, npx, or corepack.

### Building

Use `./docker-build.sh` to build, scan, and optionally push:

```bash
./docker-build.sh                            # Local build + vulnerability scan
./docker-build.sh --push                     # Build, scan, and push to registry
./docker-build.sh --platform linux/arm64     # Local ARM64 build + scan
./docker-build.sh --push --platform linux/amd64,linux/arm64  # Multi-arch push
```

### Build types

The script determines the image tag automatically based on the git state:

| State | Tag format | Example |
|---|---|---|
| Clean + matching git tag | `<version>` | `0.1.3` |
| Clean + no matching tag | `<version>-dev-<sha>` | `0.1.3-dev-a1b2c3d` |
| Uncommitted changes | `<version>-dirty-<sha>` | `0.1.3-dirty-a1b2c3d` |

The `latest` tag is only applied to **release** builds.

### Security

- The image runs as UID `65532` (nonroot).
- Every build is scanned for vulnerabilities before any push is allowed.
- Pushes are blocked if the scan finds issues at or above the configured severity threshold.

## Tech Stack

- Next.js 16 with React 19
- TypeScript
- Tailwind CSS 4
- Biome for linting/formatting
- Bun for package management
- Docker with distroless Node.js 24 for production images