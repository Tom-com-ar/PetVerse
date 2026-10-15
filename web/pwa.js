(() => {
  const installButton = document.querySelector('#pwa-install-button');
  const installHelp = document.querySelector('#pwa-install-help');
  const installInstructions = document.querySelector('#pwa-install-instructions');
  const closeHelpButton = document.querySelector('#pwa-install-close');
  let pendingInstallPrompt = null;

  const isInstalled =
    window.matchMedia('(display-mode: standalone)').matches ||
    window.navigator.standalone === true;

  if (isInstalled) installButton.hidden = true;

  const showInstallInstructions = () => {
    const userAgent = window.navigator.userAgent;
    const isIos =
      /iphone|ipad|ipod/i.test(userAgent) ||
      (window.navigator.platform === 'MacIntel' && window.navigator.maxTouchPoints > 1);
    const isAndroid = /android/i.test(userAgent);
    const isChromeOrEdge = /chrome|crios|edg/i.test(userAgent);

    if (isIos) {
      installInstructions.textContent =
        'En Safari, tocá Compartir y elegí “Agregar a pantalla de inicio”.';
    } else if (isAndroid && isChromeOrEdge) {
      installInstructions.textContent =
        'Abrí el menú ⋮ de Chrome o Edge y elegí “Instalar aplicación” o “Agregar a pantalla principal”.';
    } else if (isChromeOrEdge) {
      installInstructions.textContent =
        'Abrí el menú ⋮ de Chrome o Edge y elegí “Instalar PetVerse” en “Guardar y compartir”. También puede aparecer el ícono de instalación junto a la dirección.';
    } else {
      installInstructions.textContent =
        'Abrí el menú del navegador y buscá “Instalar aplicación” o “Agregar a pantalla de inicio”.';
    }

    installHelp.showModal();
  };

  window.addEventListener('beforeinstallprompt', (event) => {
    event.preventDefault();
    pendingInstallPrompt = event;
    installButton.hidden = false;
  });

  installButton.addEventListener('click', async () => {
    if (!pendingInstallPrompt) {
      showInstallInstructions();
      return;
    }

    await pendingInstallPrompt.prompt();
    pendingInstallPrompt = null;
  });

  closeHelpButton.addEventListener('click', () => installHelp.close());

  window.addEventListener('appinstalled', () => {
    pendingInstallPrompt = null;
    installButton.hidden = true;
    if (installHelp.open) installHelp.close();
  });

  if ('serviceWorker' in navigator) {
    window.addEventListener('load', () => {
      navigator.serviceWorker.register('./service_worker.js').catch((error) => {
        console.error('No se pudo registrar el service worker de PetVerse.', error);
      });
    });
  }
})();
