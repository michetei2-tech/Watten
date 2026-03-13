let deferredPrompt = null;

window.addEventListener('beforeinstallprompt', (e) => {
  e.preventDefault();
  deferredPrompt = e;
  window.dispatchEvent(new Event('pwa-install-available'));
});

window.pwaInstall = async () => {
  if (!deferredPrompt) return false;
  deferredPrompt.prompt();
  deferredPrompt = null;
  return true;
};
