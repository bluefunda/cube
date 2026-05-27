(function () {
  function inject() {
    if (document.getElementById('sso-logout-btn')) return true;

    // Find Slack link by text content
    var slack = null;
    var links = document.querySelectorAll('a');
    for (var i = 0; i < links.length; i++) {
      if (links[i].textContent.trim().toLowerCase() === 'slack') {
        slack = links[i];
        break;
      }
    }
    if (!slack) return false;

    var btn = document.createElement('a');
    btn.id = 'sso-logout-btn';
    btn.title = 'Sign Out';
    btn.style.cssText = [
      'display:inline-flex',
      'align-items:center',
      'justify-content:center',
      'margin-left:16px',
      'cursor:pointer',
      'opacity:0.85',
      'transition:opacity 0.2s',
      'color:#ffffff',
      'text-decoration:none',
    ].join(';');

    btn.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#ffffff" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/></svg>';

    btn.onmouseover = function () { this.style.opacity = '1'; };
    btn.onmouseout  = function () { this.style.opacity = '0.85'; };

    btn.onclick = function (e) {
      e.preventDefault();
      window.location.href = '/oauth2/sign_out';
    };

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
