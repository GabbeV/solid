const fs = require("node:fs");
const path = require("node:path");
const http = require("node:http");
const assert = require("node:assert/strict");
const { chromium } = require("/workspace/pr3886/browser/node_modules/playwright");

(async () => {
  const server = http.createServer((req, res) => {
    const name = req.url.slice(1);
    if (!["prod.html", "dev.html", "prod.js", "dev.js"].includes(name)) {
      res.writeHead(404); res.end(); return;
    }
    res.setHeader("Content-Type", name.endsWith(".js") ? "text/javascript" : "text/html");
    res.end(fs.readFileSync(path.join(__dirname, name)));
  });
  await new Promise(resolve => server.listen(0, "127.0.0.1", resolve));
  const browser = await chromium.launch({
    executablePath: "/usr/bin/chromium", headless: true, args: ["--no-sandbox"]
  });
  const results = [];
  try {
    for (const tier of ["prod", "dev"]) {
      for (const order of ["id-first", "pending-first"]) {
        const page = await browser.newPage();
        const errors = [];
        page.on("pageerror", error => errors.push(error.message));
        await page.goto(`http://127.0.0.1:${server.address().port}/${tier}.html`);
        const panel = page.locator(`#${order}`);
        const read = () => panel.locator("output").allTextContents();
        const initial = await read();
        await panel.getByRole("button").click();
        await page.waitForTimeout(200);
        const during = await read();
        await page.screenshot({ path: path.join(__dirname, `${tier}-${order}.png`), fullPage: true });
        await page.waitForTimeout(3200);
        const after = await read();
        await page.waitForTimeout(3200);
        const later = await read();
        results.push({ tier, order, initial, during, after, later, errors });
        await page.close();
      }
    }
    fs.writeFileSync(path.join(__dirname, "browser-results.json"), JSON.stringify(results, null, 2));
    console.log(JSON.stringify(results, null, 2));
    for (const result of results) {
      assert.deepEqual(result.initial, ["0", "0", "false"]);
      assert.deepEqual(result.after.slice(0, 2), ["1", "10"]);
      assert.deepEqual(result.during, result.order === "id-first"
        ? ["0", "0", "true"] : ["1", "0", "true"]);
      assert.deepEqual(result.errors, []);
    }
  } finally {
    await browser.close();
    server.close();
  }
})();
