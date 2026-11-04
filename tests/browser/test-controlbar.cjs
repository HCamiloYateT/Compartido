const assert = require('node:assert/strict');
const fs = require('node:fs/promises');
const path = require('node:path');
const { chromium } = require('playwright');
(async () => {
  const browser = await chromium.launch({executablePath:process.env.CHROMIUM_PATH,
    args:process.env.CI ? ['--no-sandbox'] : []});
  const url = process.env.COMPARTIDO_CONTROLBAR_URL || 'http://127.0.0.1:4061';
  const script = await fs.readFile(path.join(__dirname, '../../Scripts/controlbar.js'), 'utf8');
  const errors = [];
  let checks = 0;
  const check = (value, message) => { assert.ok(value, message); checks++; };
  async function open(query = '') {
    const page = await browser.newPage({viewport:{width:1440, height:1000}});
    page.on('pageerror', error => errors.push(error.message));
    await page.goto(url + query);
    await page.waitForFunction(() => window.Shiny && Shiny.shinyapp?.$socket?.readyState === 1);
    if (!query.includes('bar=0')) await page.locator('#demo-state').filter({hasText:'confirmed'}).waitFor();
    return page;
  }
  async function bar(page) {
    if (!await isOpen(page)) await page.locator('[data-widget="control-sidebar"]').click();
    await page.waitForFunction(() => document.body.classList.contains('control-sidebar-slide-open'));
  }
  const isOpen = page => page.evaluate(() => document.body.classList.contains('control-sidebar-slide-open'));
  async function choose(page, id, text, multiple = false, portal = multiple) {
    const picker = page.locator(`.bootstrap-select:has(#${id})`);
    await picker.locator('button.dropdown-toggle').click();
    const menu = portal ? page.locator('body > .bs-container .dropdown-menu') : picker.locator('.dropdown-menu');
    await menu.locator('li').filter({hasText:text}).last().click();
    if (multiple) {
      check(await picker.locator('button.dropdown-toggle').getAttribute('aria-expanded') === 'true',
        'La selección múltiple mantiene el menú abierto');
      await picker.locator('button.dropdown-toggle').click();
    }
  }
  try {
    // Caso nativo: ninguna dependencia JavaScript de racafeForms puede enmascarar el fallo.
    const native = await open('?script=0');
    await bar(native);
    await native.locator('#demo-tabs a').filter({hasText:'Fechas y modales'}).click();
    await native.locator('#demo-modal').click();
    await native.locator('#demo-notes').click();
    await native.waitForFunction(() => !document.body.classList.contains('control-sidebar-slide-open'));
    check(!await isOpen(native), 'Sin el recurso, el modal asociado reproduce el cierre involuntario');
    await native.close();

    for (const rf of [0, 1]) {
      const page = await open(`?rf=${rf}`);
      await page.locator('#demo-text').waitFor({state:'attached'});
      await bar(page);
      await page.locator('#demo-text').fill('Texto reactivo');
      await page.locator('#demo-number').press('ControlOrMeta+A');
      await page.locator('#demo-number').pressSequentially('1234.56');
      await page.locator('#demo-number').press('Tab');
      await choose(page, 'demo-single', 'Cacao');
      await choose(page, 'demo-multi', 'Cacao', true);
      const search = page.locator('.bootstrap-select:has(#demo-search)');
      await search.locator('button.dropdown-toggle').click();
      await search.locator('.bs-searchbox input').fill('Té');
      await search.locator('.dropdown-menu li').filter({hasText:'Té'}).last().click();
      await page.waitForFunction(() => {
        const state = document.querySelector('#demo-state').textContent;
        return state.includes('Texto reactivo') && state.includes('1234.56') && state.includes('cacao') &&
          state.includes('"te"');
      });
      check(await isOpen(page), `Inputs y selectores conservan el panel (rf=${rf})`);
      await page.locator('#demo-renew').click();
      await page.locator('label[for="demo-dynamic"]').filter({hasText:'Dinámico 1'}).waitFor();
      await choose(page, 'demo-dynamic', 'Cacao', false, true);
      check(await page.locator('#demo-dynamic').inputValue() === 'cacao', 'renderUI conserva binding y selección');
      await page.locator('#demo-tabs a').filter({hasText:'Fechas y modales'}).click();
      await page.locator('#demo-date').click();
      const airDay = page.locator('.air-datepicker.-active- .air-datepicker-cell.-day-:not(.-other-month-)').nth(14);
      const date = await airDay.evaluate(el => new Date(Date.UTC(+el.dataset.year, +el.dataset.month,
        +el.dataset.date)).toISOString().slice(0,10));
      await airDay.click();
      check(await isOpen(page), 'Air Datepicker fuera del panel no lo cierra');
      await page.locator('#demo-tabs a').filter({hasText:'Fechas y modales'}).click();
      await page.locator('#demo-range input').first().click();
      const startDay = page.locator('.datepicker-dropdown:visible .datepicker-days td.day:not(.old):not(.new)').nth(12);
      const start = await startDay.evaluate(el => new Date(+el.dataset.date).toISOString().slice(0,10));
      await startDay.click();
      await page.locator('#demo-range input').last().click();
      const endDay = page.locator('.datepicker-dropdown:visible .datepicker-days td.day:not(.old):not(.new)').nth(16);
      const end = await endDay.evaluate(el => new Date(+el.dataset.date).toISOString().slice(0,10));
      await endDay.click();
      await page.waitForFunction(({date, start, end}) => {
        const state = document.querySelector('#demo-state').textContent;
        return [date, start, end].every(value => state.includes(value));
      }, {date, start, end}); checks++;

      check(await isOpen(page), 'El rango de fechas no cierra el panel');
      await page.locator('#demo-modal').click();
      await page.locator('#demo-notes').fill('Nota del modal');
      await page.locator('#demo-confirm').click();
      await page.waitForFunction(() => {
        const state = document.querySelector('#demo-state').textContent;
        return /\$confirmed\s+\[1\] 1/.test(state) && state.includes('Nota del modal');
      });
      check(await isOpen(page), 'La confirmación nativa actualiza Shiny sin cerrar el controlbar');
      check((await page.locator('#demo-state').textContent()).includes('Nota del modal'), 'Binding dentro del modal');
      if (rf) {
        await page.locator('#demo-alert').click();
        await page.locator('.swal2-confirm').click();
        await page.waitForFunction(() => /\$accepted\s+\[1\] TRUE/.test(document.querySelector('#demo-state').textContent));
        check(await isOpen(page), 'SweetAlert asociado conserva el controlbar y transmite la confirmación');
      }
      await page.locator('#demo-tabs a').filter({hasText:'Cotizador'}).click();
      await page.locator('.cot-resumen-tabla td').first().waitFor();
      const styles = await page.evaluate(() => {
        const style = selector => getComputedStyle(document.querySelector(selector));
        return {gap:style('.cot-product-total').columnGap, padding:style('.cot-resumen-tabla td').padding,
          font:style('.cot-resumen-tabla table').fontSize, header:style('.cot-resumen-tabla th').fontSize,
          adjacent:style('.cotizador-producto-grid + .cotizador-producto-grid').marginTop,
          max:style('.cot-resumen-modal').maxHeight, unrelated:style('#outside_table td').padding};
      });
      assert.deepEqual([styles.gap, styles.padding, styles.font, styles.header, styles.adjacent, styles.max],
        ['8px','4px 5px','11px','10.5px','10px','550px']); checks++;
      check(styles.unrelated !== styles.padding, 'Los estilos del Cotizador no afectan la tabla ajena');
      check(await isOpen(page), 'Cambiar tabs conserva el controlbar');
      check(await page.locator('aside.control-sidebar').getAttribute('data-pin') !== 'true', 'El panel no queda fijado');
      await page.locator('[data-widget="control-sidebar"]').click();
      await page.waitForFunction(() => !document.body.classList.contains('control-sidebar-slide-open'));
      check(true, 'Cierre manual nativo');
      await bar(page);
      await page.locator('#outside').click();
      await page.waitForFunction(() => !document.body.classList.contains('control-sidebar-slide-open'));
      check(true, 'Cierre mediante clic fuera');
      await bar(page);
      // Un modal ajeno, que ya estaba abierto antes del clic del panel, no se atribuye al panel.
      await page.locator('#outside_modal').click();
      await page.locator('#outside_notes').click();
      await page.locator('#outside_notes').fill('Ajeno');
      check(!await isOpen(page), 'El modal ajeno no obtiene la protección del controlbar');
      await page.locator('.modal.show [data-dismiss="modal"]').click();
      await page.waitForFunction(() => !document.querySelector('.modal.show'));
      await bar(page);
      await page.evaluate(() => {
        window.controlbarAdds = 0;
        window.originalAdd = document.addEventListener;
        document.addEventListener = function (...args) { window.controlbarAdds++; return originalAdd.apply(this, args); };
      });
      await page.addScriptTag({content:script});
      await page.addScriptTag({content:script});
      check(await page.evaluate(() => { document.addEventListener = originalAdd; return controlbarAdds === 0; }),
        'Cargar el script repetido no registra más listeners');
      await page.close();
    }

    // Verifica las familias de popups admitidas y la propagación en document.
    const page = await open();
    await bar(page);
    for (const name of ['modal show', 'modal-backdrop', 'daterangepicker', 'bootstrap-datetimepicker-widget',
      'datepicker', 'datepicker-dropdown', 'flatpickr-calendar', 'ui-datepicker', 'clockpicker-popover',
      'select2-container--open', 'swal2-container', 'air-datepicker', 'bs-container', 'rf-select-menu']) {
      await page.locator('#demo-text').focus();
      const state = await page.evaluate(async name => {
        const popup = document.createElement('div'); popup.className = name;
        popup.style.cssText = 'display:block;position:fixed;top:100px;left:200px;width:150px;height:50px;z-index:5000';
        const child = document.createElement('span'); child.textContent = 'Probe'; popup.appendChild(child);
        document.body.appendChild(popup);
        await new Promise(resolve => requestAnimationFrame(resolve));
        let atDocument = 0, atWindow = 0;
        const doc = event => { if (event.target === child) atDocument++; };
        const win = event => { if (event.target === child) atWindow++; };
        document.addEventListener('click', doc); window.addEventListener('click', win);
        const event = new MouseEvent('click', {bubbles:true, cancelable:true}); child.dispatchEvent(event);
        document.removeEventListener('click', doc); window.removeEventListener('click', win); popup.remove();
        return {atDocument, atWindow, prevented:event.defaultPrevented};
      }, name);
      assert.deepEqual(state, {atDocument:1, atWindow:0, prevented:false}, name); checks++;
    }
    await page.close();
    const plain = await open('?bar=0');
    await plain.locator('#outside_text').fill('Sin controlbar');
    await plain.locator('#outside_modal').click();
    await plain.locator('#outside_notes').fill('Funciona');
    await plain.locator('.modal.show [data-dismiss="modal"]').click();
    check(await plain.locator('aside.control-sidebar').count() === 0, 'Sin controlbar no se requieren elementos ni IDs');
    check(await plain.locator('#outside_text').inputValue() === 'Sin controlbar', 'La app sin panel conserva sus controles');
    check(errors.length === 0, errors.join('; '));
    console.log(`${checks} comprobaciones de controlbar, binding, popups y CSS superadas.`);
  } finally { await browser.close(); }
})().catch(error => { console.error(error); process.exitCode = 1; });
