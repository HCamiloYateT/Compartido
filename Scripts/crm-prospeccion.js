(function ($) {
  "use strict";
  if (window.racafeCrmProspeccion) return;
  window.racafeCrmProspeccion = true;
  // Captura antes del despacho genérico de racafeModulos; no cambia sus otras acciones.
  document.addEventListener("click", function (event) {
    var button = event.target.closest && event.target.closest('[data-rm-action="Consultar"]');
    if (!button) return;
    event.preventDefault();
    event.stopImmediatePropagation();
    if (window.Shiny) Shiny.setInputValue("PR_Consultar", {
      codigo: button.dataset.rmCode || "", nit: button.dataset.crmNit || "", ts: Date.now()
    }, {priority: "event"});
    var panel = button.closest(".rc-panel-acciones");
    if (panel) panel.style.display = "none";
  }, true);
  // Una señal por montaje, cuando Shiny ya enlazó los controles del formulario.
  $(document).on("shiny:bound.crmFormulario", function (event) {
    // Un control puede pertenecer a un submódulo y al formulario contenedor.
    $(event.target).parents("[data-crm-form-ready]").addBack("[data-crm-form-ready]").each(function () {
      var root = this;
      if (root.dataset.crmFormSent) return;
      root.dataset.crmFormSent = "true";
      window.setTimeout(function () {
        if (root.isConnected && window.Shiny) Shiny.setInputValue(root.dataset.crmFormReady,
          Date.now(), {priority: "event"});
      }, 0);
    });
  });
}(window.jQuery));
