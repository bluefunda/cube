(function () {
  function inject() {
    var slack = document.querySelector('a[href*="slack"]');
    if (!slack) return false;
    if (document.getElementById('sso-logout-btn')) return true;

    var btn = document.createElement('a');
    btn.id = 'sso-logout-btn';
    btn.href = '/oauth2/sign_out';
    btn.title = 'Sign Out';
    btn.style.cssText = [
      'display:inline-flex',
      'align-items:center',
      'margin-left:8px',
      'cursor:pointer',
      'opacity:0.75',
      'transition:opacity 0.2s',
      'color:inherit',
    ].join(';');
    btn.onmouseover = function () { this.style.opacity = '1'; };
    btn.onmouseout  = function () { this.style.opacity = '0.75'; };

    // Door-with-arrow logout SVG icon (same visual weight as Slack icon)
    btn.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/></svg>';

    slack.parentNode.insertBefore(btn, slack.nextSibling);
    return true;
  }

  if (!inject()) {
    var observer = new MutationObserver(function () {
      if (inject()) observer.disconnect();
    });
    observer.observe(document.body, { childList: true, subtree: true });
  }
})();
