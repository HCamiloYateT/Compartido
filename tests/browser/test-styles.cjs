const assert = require("node:assert/strict");
const fs = require("node:fs/promises");
const path = require("node:path");
const { chromium } = require("playwright");
(async () => {
  const browser = await chromium.launch({ executablePath: process.env.CHROMIUM_PATH,
    args: process.env.CI ? ["--no-sandbox"] : [] });
  let checks = 0;
  function check(value, message) { assert.ok(value, message); checks++; }
  const url = process.env.COMPARTIDO_TEST_URL || "http://127.0.0.1:4010";
  const selectors = [".main-sidebar", ".sidebar", ".nav-sidebar", ".nav-sidebar .nav-link",
    ".nav-sidebar .nav-link.active", ".nav-sidebar .nav-link:not(.active)", ".nav-treeview",
    ".nav-treeview .nav-link", ".brand-link", ".brand-text", ".content-wrapper", ".main-header", ".main-footer"];
  const navigation = selectors.filter(selector => ![".content-wrapper", ".main-footer"].includes(selector));
  const properties = ["display", "position", "width", "height", "backgroundColor", "color", "fontFamily", "fontSize",
    "fontWeight", "lineHeight", "padding", "marginLeft", "marginBottom", "borderRadius", "overflow", "whiteSpace"];
  async function snapshot(page, list = selectors) {
    return page.evaluate(({ list, properties }) => Object.fromEntries(list.map(selector => {
      const el = document.querySelector(selector);
      if (!el) return [selector, null];
      const style = getComputedStyle(el);
      return [selector, Object.fromEntries(properties.map(key => [key, style[key]]))];
    })), { list, properties });
  }
  const errors = [], failures = [], requests = [];
  async function open(query, viewport) {
    const page = await browser.newPage({ viewport, deviceScaleFactor: 1 });
    page.on("pageerror", error => errors.push(error.message));
    page.on("response", response => { if (response.status() >= 400) errors.push(`HTTP ${response.status()}: ${response.url()}`); });
    page.on("requestfailed", request => failures.push(request.url()));
    await page.route("**/*", route => {
      const address = new URL(route.request().url());
      requests.push(address.href);
      if (address.origin !== new URL(url).origin) return route.abort();
      return route.continue();
    });
    await page.goto(url + query);
    await page.locator("#demo1-valores").filter({ hasText: "importe" }).waitFor({ state: "attached" });
    await page.waitForFunction(() => !document.documentElement.classList.contains("shiny-busy"));
    return page;
  }
  try {
    const desktop = { width: 1440, height: 1100 };
    const reference = await open("?mode=reference", desktop);
    const current = await open("?mode=generated", desktop);
    const rules = page => page.locator("#corporate-css").evaluate(el => {
      const root = getComputedStyle(document.documentElement), normalized = [];
      for (const rule of el.sheet.cssRules) {
        const modalTokens = rule.selectorText === ":root" && Array.from(rule.style)
          .some(name => name.startsWith("--rf-modal-"));
        const modalSize = rule.selectorText && rule.selectorText.startsWith(".rf-modal") && rule.style &&
          rule.style.getPropertyValue("max-width").includes("--rf-modal-max-");
        if (modalTokens || modalSize) continue;
        normalized.push(rule.cssText.replace(/var\((--rf-modal-max-[\w-]+)\)/g,
          (_, name) => root.getPropertyValue(name).trim()));
      }
      const sheet = new CSSStyleSheet(); sheet.replaceSync(normalized.join("\n"));
      return Array.from(sheet.cssRules, rule => {
        if (rule.selectorText === ':root') {
          ['--color-red-surface', '--color-warning-text'].forEach(name => rule.style.removeProperty(name));
        }
        return rule.cssText;
      });
    });
    const generated = await rules(current), original = await rules(reference);
    let position = -1;
    for (const rule of original) {
      position = generated.indexOf(rule, position + 1);
      assert.ok(position >= 0, `Regla anterior conservada y ordenada: ${rule.slice(0, 120)}`);
    }
    check(true, "Se conservan las reglas anteriores y su precedencia; se permiten componentes rf- nuevos");
    const before = await snapshot(reference), after = await snapshot(current);
    for (const selector of selectors) {
      check(after[selector] !== null, `Existe ${selector}`);
      assert.deepEqual(after[selector], before[selector], `Regresión visual en ${selector}`); checks++;
    }
    const firstSidebar = await reference.locator(".main-sidebar").screenshot({ animations: "disabled" });
    const secondSidebar = await current.locator(".main-sidebar").screenshot({ animations: "disabled" });
    check(firstSidebar.equals(secondSidebar), "Sidebar idéntico píxel a píxel a la referencia con imports expandidos");
    const css = await current.locator("#corporate-css").textContent();
    check(css.includes("--color-red-primary: #DA291C"), "Tokens disponibles dentro de style inline");
    check(!css.includes("@import"), "CSS inline sin imports relativos");
    check(await current.locator(".content-wrapper .rf-form").count() === 9, "Nueve combinaciones de variantes y densidades");
    for (let i = 1; i <= 9; i++) {
      const form = current.locator(`#demo${i}-form`);
      const state = await form.evaluate(el => {
        const style = getComputedStyle(el), field = getComputedStyle(el.querySelector("input.form-control"));
        return { background: style.backgroundColor, border: style.borderTopWidth, height: field.height,
          radius: field.borderRadius };
      });
      check(state.height === (i % 3 === 0 ? "40px" : "36px"), `Altura corporativa: formulario ${i}`);
      check(state.radius === "18px", `Borde de campo corporativo: formulario ${i}`);
      check(i <= 3 ? state.background === "rgba(0, 0, 0, 0)" && state.border === "0px" :
        i <= 6 ? state.background === "rgb(245, 245, 245)" : state.background === "rgb(255, 255, 255)",
      `Superficie conservada: formulario ${i}`);
    }
    check(await current.locator("#demo1-guardar").evaluate(el => getComputedStyle(el).backgroundColor) ===
      "rgb(218, 41, 28)", "Rojo Racafé del botón principal");
    await current.locator("#demo1-categoria").evaluate(el => window.jQuery(el).selectpicker("val", "Café").trigger("change"));
    await current.locator("#demo1-nombre").fill("Cliente de prueba");
    await current.locator("#demo1-activo").focus(); await current.locator("#demo1-activo").press("Space");
    await current.locator("#demo1-guardar").click();
    await current.locator("#demo1-resultado .rf-message--success").waitFor();
    check((await current.locator("#demo1-valores").innerText()).includes("TRUE"), "Switch lógico y binding activos");
    await current.locator("#demo1-fecha").click();
    await current.locator(".air-datepicker:visible").waitFor();
    check(true, "Calendario fecha-hora abre al pulsar el campo");
    await current.locator("#demo1-nombre").click();
    await current.locator("#demo1-modal").click();
    await current.locator(".rf-modal:visible").waitFor();
    check(await current.locator(".rf-modal .modal-content").evaluate(el => getComputedStyle(el).borderRadius) === "12px",
      "Modal corporativo conserva su estilo");
    await current.locator(".rf-modal [data-dismiss='modal']").click();
    await current.locator(".rf-modal:visible").waitFor({ state: "hidden" });
    const noForms = await browser.newPage({ viewport: desktop });
    await noForms.goto(url + "?forms=0");
    await noForms.locator(".nav-sidebar .nav-link.active").waitFor();
    assert.deepEqual(await snapshot(noForms, navigation), Object.fromEntries(navigation.map(key => [key, before[key]])));
    check(true, "Añadir formularios no altera navegación, marca, iconos ni navbar");
    await current.locator(".nav-link[data-value='clientes']").click();
    await reference.locator(".nav-link[data-value='clientes']").click();
    const active = await snapshot(current, [".nav-treeview .nav-link.active"]);
    assert.deepEqual(active, await snapshot(reference, [".nav-treeview .nav-link.active"]));
    check(active[".nav-treeview .nav-link.active"] !== null, "Submenú activo conserva estilos");
    await reference.locator("#demo1-nombre").fill("Cliente de prueba");
    await reference.locator("#demo1-activo").focus(); await reference.locator("#demo1-activo").press("Space");
    await reference.locator("#demo1-guardar").click();
    await reference.locator("#demo1-resultado .rf-message--success").waitFor();
    for (const page of [reference, current]) await page.setViewportSize({ width: 390, height: 844 });
    for (const page of [reference, current]) {
      await page.waitForFunction(() => Math.round(document.querySelector('.main-header').getBoundingClientRect().width) <= innerWidth);
    }
    await current.waitForTimeout(400);
    assert.deepEqual(await snapshot(current), await snapshot(reference));
    check(true, "Navegación y layout móvil iguales a la referencia");
    const components = await fs.readFile(path.join(__dirname, "../../Styles/racafe-forms.css"), "utf8") +
      await fs.readFile(path.join(__dirname, "../../Styles/racafe-modal-sizes.css"), "utf8");
    const scoped = await current.evaluate(text => {
      const sheet = new CSSStyleSheet(); sheet.replaceSync(text);
      function valid(rules) {
        return Array.from(rules).every(rule => {
          if (rule.type === CSSRule.KEYFRAMES_RULE) return true;
          if (rule.selectorText) return rule.selectorText === ":root" ?
            Array.from(rule.style).every(property => property.startsWith("--rf-")) :
            rule.selectorText.split(",").every(selector => selector.trim().startsWith(".rf-"));
          return !rule.cssRules || valid(rule.cssRules);
        });
      }
      return valid(sheet.cssRules);
    }, components);
    check(scoped, "Las reglas nuevas de componentes no alcanzan Bootstrap ni navegación");
    const imports = ["tokens.css", "racafe-forms.css"].map(file => new URL(file, url).href);
    check(!requests.some(address => imports.includes(address)), "Ninguna petición relativa de CSS desde style inline");
    check(errors.length === 0, `Sin errores JavaScript: ${errors.join("; ")}`);
    check(failures.length === 0, `Sin dependencias fallidas: ${failures.join("; ")}`);
    console.log(`${checks} comprobaciones CSS/bs4Dash superadas.`);
    await noForms.close(); await current.close(); await reference.close();
  } finally { await browser.close(); }
})().catch(error => { console.error(error); process.exitCode = 1; });
