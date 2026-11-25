(function () {
  function register() {
    if (!window.Shiny || typeof window.Shiny.addCustomMessageHandler !== "function") return;
    window.Shiny.addCustomMessageHandler("crm-carga", function (visible) {
      const overlay = document.getElementById("crm-carga");
      if (overlay) overlay.hidden = !visible;
    });
  }
  if (window.Shiny && typeof window.Shiny.addCustomMessageHandler === "function") {
    register();
  } else {
    document.addEventListener("DOMContentLoaded", register, { once: true });
  }
}());
