# Getting Started

## Where to go in the portal

1. **Catalog** — browse systems and components. Every entity shows its owning
   team and its repository.
2. **Create** — pick the golden-path template, give the service a name and an
   owner, and choose the repository it should be created in. The platform
   publishes the repo, registers the service, and notifies the owning group.
3. **Docs** — each service's `docs/` folder is rendered automatically.

## Clone a generated service

After creating a service, open its catalog entry and use the **copy clone URL**
button, then clone it yourself:

```sh
git clone <the-service-url>
cd <service-name>
npm start
```

## Adding your own docs

Write plain Markdown in your service's `docs/` directory with an `mkdocs.yml`
at the service root. The platform builds and serves it automatically.