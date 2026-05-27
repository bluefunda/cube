(function () {
  function inject() {
    if (document.getElementById('sso-logout-btn')) return true;

    // Find the Slack link by text content (more reliable than href match)
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
      'gap:5px',
      'margin-left:12px',
      'padding:4px 12px',
      'background:#ff4d4f',
      'color:#ffffff',
      'border-radius:6px',
      'font-size:13px',
      'font-weight:500',
      'font-family:-apple-system,BlinkMacSystemFont,sans-serif',
      'cursor:pointer',
      'text-decoration:none',
      'line-height:1.6',
      'transition:background 0.2s',
    ].join(';');

    btn.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/></svg>Sign Out';

    btn.onmouseover = function () { this.style.background = '#d9363e'; };
    btn.onmouseout  = function () { this.style.background = '#ff4d4f'; };

    // Use window.location to bypass React Router intercepting the click
    btn.onclick = function (e) {
      e.preventDefault();
      window.location.href = '/oauth2/sign_out';
    };

    // Insert after Slack in the same container
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
