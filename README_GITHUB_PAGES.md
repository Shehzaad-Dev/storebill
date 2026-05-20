GitHub Pages — Publish `privacy.html` and `terms.html`

Option 1 — Use `gh-pages` branch (recommended for simple sites)
1. Ensure `privacy.html` and `terms.html` are in repo root or `docs/` folder.
2. Create `gh-pages` branch and push HTML files:

```bash
git checkout --orphan gh-pages
git reset --hard
mkdir -p docs
cp privacy.html terms.html docs/
git add docs
git commit -m "Publish privacy and terms"
git push origin gh-pages
```
3. In GitHub repository settings → Pages, set source to `gh-pages` branch `/ (root)` or `/docs` accordingly.
4. Wait a few minutes, then verify:
   - https://<your-username>.github.io/<repo-name>/privacy.html
   - https://<your-username>.github.io/<repo-name>/terms.html

Option 2 — Use `main` branch and `docs/` folder
1. Add files to `docs/` and push to `main`:

```bash
mkdir -p docs
cp privacy.html terms.html docs/
git add docs/privacy.html docs/terms.html
git commit -m "Add privacy and terms for GH Pages"
git push origin main
```
2. In GitHub → Settings → Pages, select `main` branch and `/docs` folder as source.
3. Verify URLs after propagation.

Notes
- Use HTTPS links in Play Console and App Store Connect.
- GitHub Pages path example: `https://<username>.github.io/<repo>/privacy.html`.
- If you prefer a custom domain, configure CNAME in Pages settings.

Troubleshooting
- If 404, re-check branch and folder settings and wait 10 minutes for propagation.
- For styling, you can add simple CSS inside `privacy.html`/`terms.html` as already included.
