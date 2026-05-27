(function () {
  if (document.getElementById('sso-logout-btn')) return;

  var btn = document.createElement('div');
  btn.id = 'sso-logout-btn';
  btn.title = 'Sign Out';
  btn.innerHTML = [
    '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24"',
    '  fill="none" stroke="#ffffff" stroke-width="2.2"',
    '  stroke-linecap="round" stroke-linejoin="round">',
    '  <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/>',
    '  <polyline points="16 17 21 12 16 7"/>',
    '  <line x1="21" y1="12" x2="9" y2="12"/>',
    '</svg>',
    '<span style="margin-left:6px;font-size:13px;font-weight:500;color:#ffffff;font-family:-apple-system,BlinkMacSystemFont,sans-serif">Sign Out</span>',
  ].join('');

  btn.style.cssText = [
    'position:fixed',
    'top:10px',
    'right:16px',
    'z-index:99999',
    'display:inline-flex',
    'align-items:center',
    'background:rgba(255,77,79,0.90)',
    'padding:6px 12px',
    'border-radius:6px',
    'cursor:pointer',
    'box-shadow:0 2px 6px rgba(0,0,0,0.25)',
    'transition:background 0.2s',
    'user-select:none',
  ].join(';');

  btn.onmouseover = function () { this.style.background = 'rgba(255,77,79,1)'; };
  btn.onmouseout  = function () { this.style.background = 'rgba(255,77,79,0.90)'; };

  // Use window.location to bypass React Router intercepting the click
  btn.onclick = function () { window.location.href = '/oauth2/sign_out'; };

  function mount() {
    if (!document.getElementById('sso-logout-btn') && document.body) {
      document.body.appendChild(btn);
    }
  }

  if (document.body) {
    mount();
  } else {
    document.addEventListener('DOMContentLoaded', mount);
  }
})();
