import Vue from "vue";
import App from "../app";
import wikilink from "../components/wikilink";

function removeInstallPrompt() {
  var installPrompt = document.getElementById("js-verification-tool");
  // It'd be more robust to get the install prompt by a special class
  // we add to it, but the version of the cmbox template on Wikidata
  // doesn't have the 'class' parameter, so do this another way:
  while (
    installPrompt &&
    installPrompt.className != "layouttemplate plainlinks"
  ) {
    installPrompt = installPrompt.nextElementSibling;
  }
  if (installPrompt) {
    installPrompt.style.display = "none";
  }
}

Vue.component("wikilink", wikilink);

function createVueApp() {
  const el = document
    .getElementById("js-verification-tool")
    .appendChild(document.createElement("verification-tool"));

  new Vue({ el, render: h => h(App) });
  removeInstallPrompt();
}

if (document.readyState !== "loading") {
  createVueApp();
} else {
  document.addEventListener("DOMContentLoaded", createVueApp);
}
